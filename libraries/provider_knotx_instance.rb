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

        @new_resource.dist_checksum_path = ::File.join(
          new_resource.install_dir, '.dist_checksum'
        )

        @new_resource.jvm_config_path = ::File.join(
          new_resource.install_dir, 'knotx.conf'
        )

        if new_resource.log_dir.nil?
          @new_resource.log_dir = ::File.join(
            node['knotx']['log_dir'], new_resource.id
          )
        end

        @new_resource.download_path = ::File.join(
          Chef::Config[:file_cache_path], new_resource.filename
        )

        @new_resource.dist_checksum = download_distribution(
          new_resource.source,
          new_resource.download_path
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
          @current_resource.dist_checksum = dist_checksum(
            new_resource.dist_checksum_path
          )

          # Consider knot.x as NOT installed if checksum doesn't match
          if current_resource.dist_checksum != new_resource.dist_checksum
            Chef::Log.info(
              "knot.x distribution checksum mismatch:\n"\
              "- current: #{current_resource.dist_checksum}\n"\
              "- new: #{new_resource.dist_checksum}"
            )
            @current_resource.installed = false
          end
        end

        @current_resource.reconfigured = knotx_reconfigured?

        # Print out all current_resource data defined so far
        current_resource.instance_variables.each do |v|
          Chef::Log.debug(
            "current_resource.#{v}"\
            " = #{current_resource.instance_variable_get(v)}"
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
      # files deployed in $KNOTX_HOME
      #
      # ---------
      # IMPORTANT
      # ---------
      # This method doesn't verify distribution checksum, as we need to make
      # sure that basic file/directory structure got deployed first. Checksum
      # is evaluated once this is passed
      def knotx_installed?
        libs =
          if ::File.directory?(new_resource.lib_dir)
            !::Dir.glob(::File.join(new_resource.lib_dir, '*')).select do |f|
              ::File.file?(f) && f.match?(/knotx-.+\.jar/)
            end.empty?
          else
            false
          end

        configs =
          if ::File.directory?(new_resource.conf_dir)
            !::Dir.glob(::File.join(new_resource.conf_dir, '*')).select do |f|
              ::File.file?(f) && f.match?(/.+\.(conf|xml|json)/)
            end.empty?
          else
            false
          end

        checksum =
          if ::File.file?(new_resource.dist_checksum_path) &&
             !::File.read(new_resource.dist_checksum_path).empty? &&
             ::File.read(new_resource.dist_checksum_path).length == 32
            true
          else
            false
          end

        Chef::Log.debug("libs = #{libs}")
        Chef::Log.debug("configs = #{configs}")
        Chef::Log.debug("checksum = #{checksum}")

        libs && configs && checksum
      end

      def knotx_reconfigured?
        # Mark as reconfigured if not yet installed or reconfiguration happend
        return true if !current_resource.installed || configure_knotx
        false
      end

      def configure_knotx
        # Update startup script
        start_script = if systemd_available?
                         systemd_script_update
                       else
                         init_script_update
                         ulimit_update
                       end

        # Update startup JVM config
        jvm_config = jvm_config_update

        # Update log config
        logback = new_resource.custom_logback ? log_config_update : false

        # Add knotx service to managed resources
        service = configure_service

        Chef::Log.debug("start_script = #{start_script}")
        Chef::Log.debug("jvm_config = #{jvm_config}")
        Chef::Log.debug("logback = #{logback}")
        Chef::Log.debug("service = #{service}")

        # Mark resource as changed if any of supprting files requires update
        status = start_script || jvm_config || logback || service
        new_resource.updated_by_last_action(status)
        status
      end

      def install_knotx
        # Execution status of all sub-resources is stored here. If anything
        # required update there will be at least one "true" in the array.
        #
        # Example:
        # * install_dir is fine, false was added
        # * lib dir permissions were wrong, true was added
        # * conf dir was fine, false was added
        # * log dir was fine, false was added
        # * distribution checksum matches, so false was added
        # * [false, true, false, false, false] was assigned to status
        # * new_resource status has to be set to true, as there's at least one
        #   true in the array
        status = []

        # Create core directory structure
        # * $KNOTX_HOME
        # * $KNOTX_HOME/lib
        # * $KNOTX_HOME/conf
        # * $KNOTX_LOG/$KNOTX_ID
        [
          new_resource.install_dir,
          new_resource.lib_dir,
          new_resource.conf_dir,
          new_resource.log_dir,
        ].each do |f|
          status << create_directory(f)
        end

        # Redeploy knot.x only if checksum doesn't match
        if current_resource.dist_checksum != new_resource.dist_checksum
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
          update_dist_checksum(
            new_resource.dist_checksum,
            new_resource.dist_checksum_path
          )

          # Update status
          status << true
        end

        Chef::Log.debug("Installation required? #{status.any?}")

        new_resource.updated_by_last_action(status.any?)
      end

      def restart_knotx
        execute_restart
      end

      # Performing install action
      def action_install
        # Install requirement check
        if !current_resource.installed
          Chef::Log.info(
            "#{new_resource.id} knot.x instance requires installation. "\
            'Installing...'
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
            'configuration has changed. Restarting...'
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
