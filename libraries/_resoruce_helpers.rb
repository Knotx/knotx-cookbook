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
      require 'rubygems'
      require 'ohai'

      @ohai = Ohai::System.new
      @ohai.all_plugins
      # Temporarily excluding Amazon Linux.
      File.directory?('/etc/systemd/system') && @ohai[:platform] != 'amazon'
    end

    def systemd_daemon_reload
      cmd_str = "systemctl daemon-reload"
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
      remote_file.owner(node['knotx']['user'])
      remote_file.group(node['knotx']['group'])
      remote_file.source(src)
      remote_file.mode('0755')
      remote_file.backup(false)

      remote_file.run_action(:create)

      # Returning downloaded file checksum
      md5sum(new_resource.download_path)
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
    def init_script_update(full_id, root_dir, log_dir)
      init_script = ::File.join('/etc/init.d/', full_id)
      template = Chef::Resource::Template.new(
        init_script,
        run_context
      )
      template.owner('root')
      template.group('root')
      template.cookbook(new_resource.knotx_init_cookbook)
      template.source(new_resource.knotx_init_path)
      template.mode('0755')
      template.variables(
        knotx_root_dir: root_dir,
        knotx_log_dir:  log_dir,
        knotx_id:       full_id,
        knotx_user:     node['knotx']['user']
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
        knotx_user:             node['knotx']['user'],
        knotx_open_file_limit:  node['knotx']['open_file_limit']
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    # Create/update systemd script
    def systemd_script_update(full_id, root_dir, log_dir)
      systemd_script = ::File.join(
        '/etc/systemd/system/', "#{full_id}.service"
      )
      template = Chef::Resource::Template.new(
        systemd_script,
        run_context
      )
      template.owner('root')
      template.group('root')
      template.cookbook(new_resource.knotx_systemd_cookbook)
      template.source(new_resource.knotx_systemd_path)
      template.mode('0755')
      template.variables(
        knotx_root_dir:         root_dir,
        knotx_log_dir:          log_dir,
        knotx_id:               full_id,
        knotx_user:             node['knotx']['user'],
        knotx_open_file_limit:  node['knotx']['open_file_limit']
      )
      template.run_action(:create)
      systemd_daemon_reload if template.updated_by_last_action?

      template.updated_by_last_action?
    end

    def jvm_config_update(
      id,
      jvm_config_path,
      app_config_path,
      app_config_extra,
      root_dir,
      log_dir,
      debug_enabled,
      jmx_enabled,
      jmx_ip,
      jmx_port,
      debug_port,
      port,
      min_heap,
      max_heap,
      max_permsize,
      code_cache,
      extra_opts,
      gc_opts
    )
      app_config_path = absolute_path(root_dir, app_config_path)

      template = Chef::Resource::Template.new(
        ::File.join(root_dir, jvm_config_path),
        run_context
      )
      template.owner(node['knotx']['user'])
      template.group(node['knotx']['group'])
      template.cookbook(new_resource.knotx_conf_cookbook)
      template.source(new_resource.knotx_conf_path)
      template.mode('0644')
      template.variables(
        knotx_id:               id,
        knotx_app_config_path:  app_config_path,
        knotx_app_config_extra: app_config_extra,
        knotx_root_dir:         root_dir,
        knotx_log_dir:          log_dir,
        debug_enabled:          debug_enabled,
        jmx_enabled:            jmx_enabled,
        jmx_ip:                 jmx_ip,
        jmx_port:               jmx_port,
        debug_port:             debug_port,
        port:                   port,
        min_heap:               min_heap,
        max_heap:               max_heap,
        max_permsize:           max_permsize,
        code_cache:             code_cache,
        extra_opts:             extra_opts,
        gc_opts:                gc_opts
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    def log_config_update(id, log_dir)
      template = Chef::Resource::Template.new(
        "#{new_resource.install_dir}/logback.xml",
        run_context
      )
      template.owner(node['knotx']['user'])
      template.group(node['knotx']['group'])
      template.cookbook(new_resource.logback_xml_cookbook)
      template.source(new_resource.logback_xml_path)
      template.mode('0644')
      template.variables(
        knotx_id:       id,
        knotx_log_dir:  log_dir,
        main_log_level: node['knotx']['log_level']['main'],
        root_log_level: node['knotx']['log_level']['root'],
        main_log_history: node['knotx']['log_history']['main'],
        root_log_history: node['knotx']['log_history']['root']
      )
      template.run_action(:create)

      template.updated_by_last_action?
    end

    def configure_service(service_name)
      service = Chef::Resource::Service.new(
        service_name,
        run_context
      )
      service.service_name(service_name)
      service.supports(status: true)
      service.run_action(:start)
      service.run_action(:enable)

      service.updated_by_last_action?
    end

    def execute_restart(service_name)
      # This restart happens exatly at the end of current knotx resource
      service = Chef::Resource::Service.new(
        "restart-#{service_name}",
        run_context
      )
      service.service_name(service_name)
      service.run_action(:restart)
    end
  end
end
