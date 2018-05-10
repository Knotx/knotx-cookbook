#
# Cookbook Name:: knotx
# Libraries:: ResourceHelper
#
# Copyright 2016 Karol Drazek
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module Knotx
  module ResourceHelpers
    # Check if systemd is available
    def systemd_available?
      File.directory?('/etc/systemd/system') && node['platform'] != 'amazon'
    end

    def systemd_daemon_reload
      cmd_str = 'systemctl daemon-reload'
      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("#{cmd_str} executed successfully: #{cmd.stdout}")
    rescue => e
      Chef::Application.fatal!("Can't reload systemd daemons: #{e}")
    end

    # Create defined directory
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

    # Get absolute path
    def absolute_path(dir, path)
      require 'pathname'

      return path if Pathname.new(path).absolute?
      Pathname.new(dir) + Pathname.new(path)
    end

    # Download of webapp package to work on it
    def download_distribution(src, dst)
      remote_file = Chef::Resource::RemoteFile.new(
        dst,
        run_context
      )
      remote_file.owner('root')
      remote_file.group('root')
      remote_file.source(src)
      remote_file.mode('0644')
      remote_file.backup(false)

      remote_file.run_action(:create)

      Chef::Log.debug("remote_file.source: #{remote_file.source}")
      Chef::Log.debug("remote_file.path: #{remote_file.path}")
      Chef::Log.debug("remote_file.atomic_update : #{remote_file.atomic_update}")
      Chef::Log.debug("remote_file.checksum : #{remote_file.checksum}")

      # Returning downloaded file checksum
      md5sum(dst)
    end

    def unzip(zip, dst_dir)
      cmd_str = "unzip -o -b #{zip} -d #{dst_dir}"
      Chef::Log.debug("Unzip command: #{cmd_str}")

      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("ZIP file was successfully extracted: #{cmd.stdout}")
    rescue => e
      Chef::Application.fatal!("Can't extract #{zip}: #{e}")
    end

    def rm_rf(dir)
      require 'fileutils'

      ::FileUtils.rm_rf(::Dir.glob(dir))
    end

    def cp_r(src, dst)
      require 'fileutils'

      ::FileUtils.cp_r(src, dst)
      ::FileUtils.chown_R(node['knotx']['user'], node['knotx']['group'], dst)
    end

    def update_dist_checksum(checksum, dst_file)
      file = Chef::Resource::File.new(dst_file, run_context)
      file.content = checksum
      file.backup = false
      file.owner(node['knotx']['user'])
      file.group(node['knotx']['group'])
      file.mode('0644')

      file.run_action(:create)
    end

    def dist_checksum(dst_file)
      ::File.file?(dst_file) ? ::File.read(dst_file) : ''
    end

    # Create/update init script
    def init_script_update
      template = Chef::Resource::Template.new(
        ::File.join('/etc/init.d', new_resource.full_id),
        run_context
      )
      template.owner('root')
      template.group('root')
      template.cookbook(new_resource.knotx_init_cookbook)
      template.source(new_resource.knotx_init_path)
      template.mode('0755')
      template.variables(
        id:        new_resource.full_id,
        java_home: node['java']['java_home'],
        home_dir:  new_resource.install_dir,
        conf_dir:  new_resource.conf_dir,
        lib_dir:   new_resource.lib_dir,
        log_dir:   new_resource.log_dir,
        user:      node['knotx']['user']
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    # Update ulimit values (valid only for Centos 6)
    def ulimit_update
      ulimit_file = '/etc/security/limits.d/knotx_limits.conf'
      template = Chef::Resource::Template.new(
        ulimit_file,
        run_context
      )
      template.owner('root')
      template.group('root')
      template.cookbook(new_resource.knotx_ulimit_cookbook)
      template.source(new_resource.knotx_ulimit_path)
      template.mode('0644')
      template.variables(
        knotx_user:            node['knotx']['user'],
        knotx_open_file_limit: node['knotx']['open_file_limit']
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    # Create/update systemd script
    def systemd_script_update
      template = Chef::Resource::Template.new(
        ::File.join('/etc/systemd/system', "#{new_resource.full_id}.service"),
        run_context
      )
      template.owner('root')
      template.group('root')
      template.cookbook(new_resource.knotx_systemd_cookbook)
      template.source(new_resource.knotx_systemd_path)
      template.mode('0755')
      template.variables(
        id:               new_resource.full_id,
        java_home:        node['java']['java_home'],
        home_dir:         new_resource.install_dir,
        conf_dir:         new_resource.conf_dir,
        lib_dir:          new_resource.lib_dir,
        user:             node['knotx']['user'],
        open_file_limit:  node['knotx']['open_file_limit']
      )
      template.run_action(:create)
      systemd_daemon_reload if template.updated_by_last_action?

      template.updated_by_last_action?
    end

    def jvm_config_update
      template = Chef::Resource::Template.new(
        new_resource.jvm_config_path,
        run_context
      )
      template.owner(node['knotx']['user'])
      template.group(node['knotx']['group'])
      template.cookbook(new_resource.knotx_conf_cookbook)
      template.source(new_resource.knotx_conf_path)
      template.mode('0644')
      template.variables(
        log_dir:       new_resource.log_dir,
        min_heap:      new_resource.min_heap,
        max_heap:      new_resource.max_heap,
        extra_opts:    new_resource.extra_opts,
        gc_opts:       new_resource.gc_opts,
        jmx_enabled:   new_resource.jmx_enabled,
        jmx_ip:        new_resource.jmx_ip,
        jmx_port:      new_resource.jmx_port,
        debug_enabled: new_resource.debug_enabled,
        debug_port:    new_resource.debug_port
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    def log_config_update
      template = Chef::Resource::Template.new(
        "#{new_resource.conf_dir}/logback.xml",
        run_context
      )
      template.owner(node['knotx']['user'])
      template.group(node['knotx']['group'])
      template.cookbook(new_resource.logback_xml_cookbook)
      template.source(new_resource.logback_xml_path)
      template.mode('0644')
      template.variables(
        log_dir:            new_resource.log_dir,
        knotx_log_history:  node['knotx']['log_history']['knotx'],
        knotx_log_size:     node['knotx']['log_size']['knotx'],
        access_log_history: node['knotx']['log_history']['access'],
        access_log_size:    node['knotx']['log_size']['access'],
        root_log_level:     node['knotx']['log_level']['root'],
        knotx_log_level:    node['knotx']['log_level']['knotx']
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    def configure_service
      service = Chef::Resource::Service.new(
        new_resource.full_id,
        run_context
      )
      service.service_name(new_resource.full_id)
      service.supports(status: true)
      service.run_action(:start)
      service.run_action(:enable)

      service.updated_by_last_action?
    end

    def execute_restart
      # This restart happens exatly at the end of current knotx resource
      service = Chef::Resource::Service.new(
        "restart-#{new_resource.full_id}",
        run_context
      )
      service.service_name(new_resource.full_id)
      service.run_action(:restart)
    end
  end
end
