#
# Cookbook Name:: knotx
# Provider:: knotx_instance
#
# Copyright (C) 2015 Karol Drazek
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

class Chef
  class Provider
    class KnotxInstance < Chef::Provider
      include Knotx::HttpHelpers
      include Knotx::LoaderHelpers
      include Knotx::ResourceHelpers

      provides :knotx_instance if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      # Downloading appropriate knotx and getting current state
      def load_current_resource
        @current_resource = Chef::Resource::KnotxInstance.new(
          new_resource.name
        )

        # TODO: This part will have to be simplified

        # ---------------------------------------------------------------------
        # New resource dynamic defaults
        # ---------------------------------------------------------------------
        if new_resource.source.nil?
          @new_resource.source =
            "#{node['knotx']['release_url']}/#{new_resource.version}/"\
            "knotx-stack-manager-#{new_resource.version}.zip"
        end

        @new_resource.filename = url_basename(new_resource.source)

        # Prefereably in future simplified naming if single instance used
        @new_resource.full_id = "knotx-#{new_resource.id}"

        if new_resource.install_dir.nil?
          @new_resource.install_dir = ::File.join(
            node['knotx']['base_dir'], new_resource.id
          )
        end

        @new_resource.lib_dir = ::File.join(
          new_resource.install_dir, 'lib'
        )

        @new_resource.conf_dir = ::File.join(
          new_resource.install_dir, 'conf'
        )

        @new_resource.tmp_dir = ::File.join(
          new_resource.install_dir, 'tmp'
        )

        @new_resource.checksum_path = ::File.join(
          new_resource.install_dir, '.dist_checksum'
        )

        @new_resource.jvm_config_path = ::File.join(
          new_resource.install_dir, "knotx.conf"
        )

        if new_resource.log_dir.nil?
          @new_resource.log_dir = node['knotx']['log_dir']
        end

        @new_resource.download_path = ::File.join(
          Chef::Config[:file_cache_path], new_resource.filename
        )

        # Print out all new_resource data defined so far
        new_resource.instance_variables.each do |v|
          Chef::Log.debug(
            "new_resource.#{v}"\
            " = #{new_resource.instance_variable_get(v)}"
          )
        end

        # Calculate knot.x instance attributes (derive from global ones if
        # anythig is missing)
        load_config_vars
        load_source_vars

        # ---------------------------------------------------------------------
        # Current resource properties
        # ---------------------------------------------------------------------
        @current_resource.installed = knotx_installed?

        if @current_resource.installed
          @current_resource.checksum_path = dist_checksum(
            new_resource.checksum_path
          )
        end

        @current_resource.reconfigured = knotx_reconfigured?

        # Print out all current_resource data defined so far
        current_resource.instance_variables.each do |v|
          Chef::Log.debug(
            "current_resource.#{v}"\
            "= #{current_resource.instance_variable_get(v)}"
          )
        end
      end

      # To consider knot.x as installed the following options have to be met:
      # * $KNOTX_HOME/lib directory exists and contains JAR files
      # * $KNOTX_HOME/conf directoru exists and contains configuration files
      # * $KNOTX_HOME/.dist_checksum exists and contains MD5 checksum
      #
      # It's not 100% accurate, as distribution ZIP content changes over time.
      # More detailed check would have to look into the ZIP file to see whether
      # its content matches to the deployed one.
      #
      # TODO: improve installation check by comparing ZIP file content with
      # files that have been deployed in $KNOTX_HOME
      def knotx_installed?
        libs = if ::File.directory?(new_resource.lib_dir)
                 ::Dir.entries(new_resource.lib_dir).select do |f|
                   ::File.file?(f) && f.match?(/knotx-.+\.jar/)
                 end.length > 0
               else
                 false
               end

        configs = if ::File.directory?(new_resource.conf_dir)
                    ::Dir.entries(new_resource.conf_dir).select do |f|
                      ::File.file?(f) && f.match?(/.+\.(conf|xml|json)/)
                    end.length > 0
                  else
                    false
                  end

        checksum = if ::File.file?(new_resource.checksum_path) &&
                       !::File.read(new_resource.checksum_path).empty? &&
                       ::File.read(new_resource.checksum_path).length == 32
                     true
                   else
                     false
                   end

        libs && configs && checksum
      end

      def knotx_reconfigured?
        # Mark as reconfigured if not yet installed or reconfiguration happend
        return true if !current_resource.installed || configure_knotx
        false
      end

      def configure_knotx
        changed = false

        # Update startup script
        if systemd_available?
          changed = true if systemd_script_update(
            new_resource.full_id,
            new_resource.install_dir,
            new_resource.log_dir
          )
        else
          changed = true if init_script_update(
            new_resource.full_id,
            new_resource.install_dir,
            new_resource.log_dir
          )
          changed = true if ulimit_update
        end

        # Update startup JVM config
        changed = true if jvm_config_update(
          new_resource.id,
          new_resource.jvm_config_path,
          new_resource.app_config_path,
          new_resource.app_config_extra,
          new_resource.install_dir,
          new_resource.log_dir,
          new_resource.debug_enabled,
          new_resource.jmx_enabled,
          new_resource.jmx_ip,
          new_resource.jmx_port,
          new_resource.debug_port,
          new_resource.port,
          new_resource.min_heap,
          new_resource.max_heap,
          new_resource.max_permsize,
          new_resource.code_cache,
          new_resource.extra_opts,
          new_resource.gc_opts
        )

        # Update logging config
        if new_resource.custom_logback
          changed = true if log_config_update(
            new_resource.id,
            new_resource.log_dir
          )
        end

        # Add knotx service to managed resources
        configure_service(new_resource.full_id)

        # We cannot assign 'changed' directly to input as it can have false
        # value and it can override status from install action
        new_resource.updated_by_last_action(true) if changed
        changed
      end

      def install_knotx
        changed = false

        # Create core directory structure
        # * $KNOTX_HOME
        # * $KNOTX_HOME/lib
        # * $KNOTX_HOME/conf
        # * $KNOTX_LOG/$KNOTX_ID
        [
          new_resource.install_dir,
          new_resource.lib_dir,
          new_resource.conf_dir,
          ::File.join(new_resource.log_dir, new_resource.id)
        ].each do |f|
          changed = true if create_directory(f)
        end

        # Download distribution ZIP file
        new_checksum = download_distribution(
          new_resource.source,
          new_resource.download_path,
        )

        Chef::Log.debug("New checksum: #{new_checksum}")

        # Redeploy knot.x if checksum doesn't match
        if current_resource.checksum_path != new_checksum
          # Get rid of exiting JAR and config files
          rm_rf(::File.join(new_resource.lib_dir, '*'))
          rm_rf(::File.join(new_resource.conf_dir, '*'))

          # Unzip the distribution
          unzip(new_resource.download_path, new_resource.tmp_dir)

          # Move relevant parts to installation dir
          cp_r(
            ::File.join(new_resource.tmp_dir, 'knotx', 'lib', '.'),
            new_resource.lib_dir
          )

          cp_r(
            ::File.join(new_resource.tmp_dir, 'knotx', 'conf', '.'),
            new_resource.conf_dir
          )

          # Remove extracted distribution
          rm_rf(new_resource.tmp_dir)

          # Update checksum
          update_dist_checksum(new_checksum, new_resource.checksum_path)
        end

        new_resource.updated_by_last_action(true) if changed
        changed
      end

      def restart_knotx
        execute_restart(new_resource.full_id)
      end

      # Performing install action
      def action_install
        # Install requirement check
        if !current_resource.installed
          Chef::Log.info(
            "#{new_resource.id} knot.x instance requires installation. "\
            ' Installing...'
          )

          install_knotx
          configure_knotx
        else
          Chef::Log.info(
            "#{new_resource.id} knot.x instance is already installed"
          )
        end

        # Restart requirement check
        if current_resource.reconfigured
          Chef::Log.info(
            "#{new_resource.id} knot.x instance will be restarted, as "\
            " configuration has changed. Restarting..."
          )

          restart_knotx
        else
          Chef::Log.info(
            "#{new_resource.id} knot.x instance doesn't require restart"
          )
        end
      rescue => e
        Chef::Application.fatal!(
          "knot.x '#{new_resource.id}' installation failed: #{e}"
        )
      end
    end
  end
end
