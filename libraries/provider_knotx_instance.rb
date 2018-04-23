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

        if new_resource.source.nil?
          ver = new_resource.version
          @new_resource.source = "#{node['knotx']['release_url']}/"\
            "#{ver}/knotx-stack-manager-#{ver}.zip"
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

        @new_resource.jvm_config_path = ::File.join(
          new_resource.install_dir, "knotx.conf"
        )

        if new_resource.log_dir.nil?
          @new_resource.log_dir = node['knotx']['log_dir']
        end

        @new_resource.download_path = ::File.join(
          Chef::Config[:file_cache_path], new_resource.filename
        )

        # Print out all instance variables defined so far
        new_resource.instance_variables.each do |v|
          Chef::Log.debug("#{v}: #{new_resource.instance_variable_get(v)}")
        end

        # Cumulative loaders for brevity
        load_config_vars
        load_git_vars
        load_source_vars

        knotx_state
      end

      def knotx_state
        @current_resource.installed = knotx_installed?
        @current_resource.reconfigured = knotx_reconfigured?
      end

      def knotx_installed?
        # To consider knot.x as installed neither lib nor conf sub-directory
        # must be empty
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

        libs && configs
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

        # Update knotx config
        changed = true if knotx_config_update

        # Update logging config
        changed = true if log_config_update(
          new_resource.id,
          new_resource.log_dir
        )

        # Add knotx service to managed resources
        configure_service(new_resource.full_id)

        # We cannot assign 'changed' directly to input as it can have false
        # value and it can override status from install action
        new_resource.updated_by_last_action(true) if changed
        changed
      end

      def install_knotx
        changed = false

        [
          new_resource.install_dir,
          "#{new_resource.install_dir}/app",
          "#{new_resource.log_dir}/#{new_resource.id}",
        ].each do |f|
          changed = true if create_directory(f)
        end

        # Copy current knotx version to install directory
        get_file(
          "file://#{new_resource.download_path}",
          new_resource.install_path
        )

        # Link current knotx version to common name
        changed = true if link_current_version(
          new_resource.install_path,
          "#{new_resource.install_dir}/app"
        )

        new_resource.updated_by_last_action(true) if changed
        changed
      end

      def restart_knotx
        execute_restart(new_resource.full_id)
      end

      # Performing install action
      def action_install
        install_required = false
        restart_required = false

        # Install requirement check
        if !current_resource.installed
          install_required = true
          Chef::Log.info("Knotx instance #{current_resource.id}' "\
            'requires installation. Installing...')
        else
          Chef::Log.info("Knotx instance '#{current_resource.id}' "\
            'is already installed in appropriate version.')
        end

        # If install is required, install knotx and perform first time config
        if install_required
          install_knotx
          configure_knotx
        end

        # Restart requirement check
        if current_resource.reconfigured
          restart_required = true
          Chef::Log.info("Knotx instance #{current_resource.id}' "\
            'requires restart. Restart scheduled...')
        else
          Chef::Log.info("Knotx instance '#{current_resource.id}' "\
            'does not require restart.')
        end

        # If restart required, restart knotx
        restart_knotx if restart_required
      rescue => e
        Chef::Application.fatal!(
          "knot.x '#{new_resource.id}' installation failed: #{e}"
        )
      end
    end
  end
end
