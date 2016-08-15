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
      include Knotx::Helper

      provides :knotx_instance if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      #########################################################################
      # CHECKS
      #########################################################################

      def knotx_state
        @current_resource.installed = knotx_installed?
      end

      # Check if appropriate knotx is installed
      def knotx_installed?
        installed = false

        # Currently deployed JAR checksum verification

        if ::File.exist?(new_resource.install_path)
          new_checksum = new_resource.checksum
          current_checksum = md5sum(new_resource.install_path)
          # If checksum doesn't match deployment is required
          installed = false unless new_checksum == current_checksum
        end

        installed
      end

      #########################################################################
      # CORE ELEMENTS
      #########################################################################

      # Download of webapp package to work on it
      def download_file
        remote_file = Chef::Resource::RemoteFile.new(
          new_resource.download_path,
          run_context
        )
        remote_file.owner(node['knotx']['user'])
        remote_file.group(node['knotx']['group'])
        remote_file.source(new_resource.source)
        remote_file.mode('0644')
        remote_file.backup(false)

        remote_file.run_action(:create)

        # Returning downloaded file checksum
        md5sum(new_resource.download_path)
      end

      def create_directory(name)
        directory = Chef::Resource::Directory.new(
          name,
          run_context
        )
        directory.owner(node['knotx']['user'])
        directory.group(node['knotx']['group'])
        directory.mode('0755')
        directory.recursive(true)

        directory.run_action(:create)

        directory.updated_by_last_action?
      end

      def init_script_update

        init_script = ::File.join('/etc/init.d/', new_resource.full_id)

        template = Chef::Resource::Template.new(
          init_script,
          run_context
        )
        template.owner('root')
        template.group('root')
        template.cookbook(node['knotx']['init_script']['source_cookbook'])
        template.source('etc/init.d/knotx.erb')
        template.mode('0755')
        template.variables(
          :knotx_root_dir  => new_resource.install_dir,
          :knotx_log_dir  => new_resource.log_dir,
          :knotx_id  => new_resource.full_id,
          :knotx_user => node['knotx']['user']
        )

        template.run_action(:create)

        template.updated_by_last_action?
      end

      def config_update
        template = Chef::Resource::Template.new(
          new_resource.config_path,
          run_context
        )
        template.owner(node['knotx']['user'])
        template.group(node['knotx']['group'])
        template.cookbook(
          node['knotx']['config']['source_cookbook']
        )
        template.source('knotx/knotx.conf.erb')
        template.mode('0644')
        template.variables(
          :jvm_min_heap => new_resource.jvm_min_heap,
          :jvm_max_heap => new_resource.jvm_max_heap
        )

        template.run_action(:create)

        template.updated_by_last_action?
      end

      def local_copy
        local_path = "file://#{new_resource.download_path}"

        remote_file = Chef::Resource::RemoteFile.new(
          new_resource.install_path,
          run_context
        )
        remote_file.owner(node['knotx']['user'])
        remote_file.group(node['knotx']['group'])
        remote_file.source(local_path)
        remote_file.mode('0755')
        remote_file.backup(false)

        remote_file.run_action(:create)
      end

      def link_knotx
        link_name = ::File.join(new_resource.install_dir, '/knotx.jar')

        link = Chef::Resource::Link.new(
          link_name,
          run_context
        )
        link.to(new_resource.install_path)

        link.run_action(:create)

        link.updated_by_last_action?
      end

      def install_knotx
        # Create base installation directory
        create_directory(new_resource.install_dir)

        # Create logging directory
        create_directory(new_resource.log_dir)

        # Configure init script
        init_script_update

        # Create config
        config_update

        # Manage current active knotx
        local_copy
        link_knotx

      end

      #########################################################################
      # MAIN ACTIONS
      #########################################################################

      def load_jvm_opts
        # Load minimum heap size
        if defined? node['knotx'][new_resource.id]['min_heap']
          @new_resource.jvm_min_heap =
            node['knotx'][new_resource.id]['min_heap']
        else
          @new_resource.jvm_min_heap = node['knotx']['min_heap']

        end
        Chef::Log.debug("Minimum heap size: #{new_resource.jvm_min_heap}")

        # Load maximum heap size
        if defined? node['knotx'][new_resource.id]['max_heap']
          @new_resource.jvm_max_heap =
            node['knotx'][new_resource.id]['max_heap']
        else
          @new_resource.jvm_max_heap = node['knotx']['max_heap']
        end
        Chef::Log.debug("Maximum heap size: #{new_resource.jvm_max_heap}")

        # Load maximum perm size
        if defined? node['knotx'][new_resource.id]['max_permsize']
          @new_resource.jvm_max_permsize =
            node['knotx'][new_resource.id]['max_permsize']
        else
          @new_resource.jvm_max_permsize = node['knotx']['max_permsize']
        end
        Chef::Log.debug("Max perm size: #{new_resource.jvm_max_permsize}")

        # Load code cache size
        if defined? node['knotx'][new_resource.id]['code_cache']
          @new_resource.jvm_code_cache =
            node['knotx'][new_resource.id]['code_cache']
        else
          @new_resource.jvm_code_cache = node['knotx']['code_cache']
        end
        Chef::Log.debug("Code cache size: #{new_resource.jvm_code_cache}")

        # Load extra opts
        if defined? node['knotx'][new_resource.id]['extra_opts']
          @new_resource.jvm_extra_opts =
            node['knotx'][new_resource.id]['extra_opts']
        else
          @new_resource.jvm_extra_opts = node['knotx']['extra_opts']
        end
        Chef::Log.debug("Extra opts: #{new_resource.jvm_extra_opts}")

        # Set JMX IP
        if defined? node['knotx'][new_resource.id]['jmx_ip']
          @new_resource.jvm_jmx_ip =
            node['knotx'][new_resource.id]['jmx_ip']
        else
          @new_resource.jvm_jmx_ip = node['knotx']['jmx_ip']
        end
        Chef::Log.debug("JMX IP: #{new_resource.jvm_jmx_ip}")

        # Set JMX port
        if defined? node['knotx'][new_resource.id]['jmx_port']
          @new_resource.jvm_jmx_port =
            node['knotx'][new_resource.id]['jmx_port']
        else
          @new_resource.jvm_jmx_port = node['knotx']['jmx_port']
        end
        Chef::Log.debug("JMX port: #{new_resource.jvm_jmx_port}")

        # Set debug port
        if defined? node['knotx'][new_resource.id]['debug_port']
          @new_resource.jvm_debug_port =
            node['knotx'][new_resource.id]['debug_port']
        else
          @new_resource.jvm_debug_port = node['knotx']['debug_port']
        end
        Chef::Log.debug("Debug port: #{new_resource.jvm_debug_port}")
      end

      # Downloading appropriate knotx and getting current state
      def load_current_resource
        @current_resource = Chef::Resource::KnotxInstance.new(new_resource.name)

        if new_resource.source.nil?
          ver = new_resource.version
          Chef::Log.debug("Knotx download version: #{new_resource.version}")

          @new_resource.source = "#{node['knotx']['release_url']}/"\
            "#{ver}/knotx-example-#{ver}.jar"

          Chef::Log.debug("Knotx download source: #{new_resource.source}")
        end

        @new_resource.filename = url_basename(new_resource.source)
        Chef::Log.debug("Knotx filename: #{new_resource.filename}")

        # Prefereably in future simplified naming if single instance used
        @new_resource.full_id = "knotx-#{new_resource.id}"
        Chef::Log.debug("Knotx filename: #{new_resource.full_id}")

        if new_resource.install_dir.nil?
          @new_resource.install_dir = ::File.join(
            node['knotx']['base_dir'], '/', new_resource.id
          )
        end
        Chef::Log.debug("Install dir: #{new_resource.install_dir}")

        @new_resource.install_path = ::File.join(
          new_resource.install_dir, '/', new_resource.filename
        )
        Chef::Log.debug(
          "Knotx install path: #{new_resource.install_path}"
        )

        @new_resource.config_path = ::File.join(
          new_resource.install_dir, '/knotx.conf'
        )
        Chef::Log.debug(
          "Knotx config path: #{new_resource.config_path}"
        )

        if new_resource.log_dir.nil?
          @new_resource.log_dir = node['knotx']['log_dir']
        end
        Chef::Log.debug("Log dir: #{new_resource.log_dir}")

        @new_resource.download_path = ::File.join(
          Chef::Config[:file_cache_path], '/', new_resource.filename
        )
        Chef::Log.debug(
          "Knotx install path: #{new_resource.download_path}"
        )

        # Cummulative JVM opts loader for brevity
        load_jvm_opts

        @new_resource.checksum = download_file

        knotx_state
      end

      # Performing install action
      def action_install
        install_required = false

        # Install requirement check
        if !current_resource.installed
          install_required = true

          Chef::Log.info("Knotx instance #{current_resource.id}' "\
            'requires installation. Installing...')
        else
          Chef::Log.info("Knotx instance '#{current_resource.id}' "\
            'is already installed in appropriate version.')
        end

        # If install is required, install knotx
        install_knotx if install_required
      rescue
        Chef::Application.fatal!(
          "Installing knotx instance '#{new_resource.id}' failed!"
        )
      end
    end
  end
end
