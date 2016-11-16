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
    include Knotx::ConfigHelpers

    # Parse repo url to include credentials
    def repo_url(address, login, password)
      require 'uri'

      uri = URI.parse(address)
      protocol = uri.scheme
      host = uri.host

      # If port is not provided, the default for given protocol is used
      port = uri.port
      path = uri.path

      return "#{protocol}://#{host}:#{port}#{path}" if
        login.empty? || password.empty?
      "#{protocol}://#{login}:#{password}@#{host}:#{port}#{path}"
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

    # Download of webapp package to work on it
    def get_file(src, dst)
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

    # Create/update init script
    def init_script_update(full_id, root_dir, log_dir)
      init_script = ::File.join('/etc/init.d/', full_id)
      template = Chef::Resource::Template.new(
        init_script,
        run_context
      )
      template.owner('root')
      template.group('root')
      template.cookbook('knotx')
      template.source('etc/init.d/knotx.erb')
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

    def jvm_config_update(
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
      min_heap,
      max_heap,
      max_permsize,
      code_cache,
      extra_opts)

      template = Chef::Resource::Template.new(
        ::File.join(root_dir, jvm_config_path),
        run_context
      )
      template.owner(node['knotx']['user'])
      template.group(node['knotx']['group'])
      template.cookbook('knotx')
      template.source('knotx/knotx.conf.erb')
      template.mode('0644')
      template.variables(
        knotx_app_config_path:  app_config_path,
        knotx_app_config_extra: app_config_extra,
        knotx_root_dir:         root_dir,
        knotx_log_dir:          log_dir,
        debug_enabled:          debug_enabled,
        jmx_enabled:            jmx_enabled,
        jmx_ip:                 jmx_ip,
        jmx_port:               jmx_port,
        debug_port:             debug_port,
        min_heap:               min_heap,
        max_heap:               max_heap,
        max_permsize:           max_permsize,
        code_cache:             code_cache,
        extra_opts:             extra_opts
      )
      template.run_action(:create)
      template.updated_by_last_action?
    end

    def get_remote_config(dir, address, login, password, revision)
      # Create config root directory
      create_directory(dir)

      # Include credentials in repo URL
      git_url = repo_url(address, login, password)

      git = Chef::Resource::Git.new(dir, run_context)
      git.repository(git_url)
      git.revision(revision)
      git.run_action(:sync)
      git.updated_by_last_action?
    end

    # TODO: Consider rewrite to File operations
    def knotx_config_update
      if new_resource.git_enabled
        get_remote_config(
          "#{new_resource.install_dir}/config",
          new_resource.git_url,
          new_resource.git_user,
          new_resource.git_pass,
          new_resource.git_revision
        )
      else
        template = Chef::Resource::Template.new(
          "#{new_resource.install_dir}/config.json",
          run_context
        )
        template.owner(node['knotx']['user'])
        template.group(node['knotx']['group'])
        template.cookbook('knotx')
        template.source('knotx/config.json.erb')
        template.mode('0644')
        template.variables(generated_config: generate_config)
        template.run_action(:create)
        template.updated_by_last_action?
      end
    end

    def log_config_update
      template = Chef::Resource::Template.new(
        "#{new_resource.install_dir}/logback.xml",
        run_context
      )
      template.owner(node['knotx']['user'])
      template.group(node['knotx']['group'])
      template.cookbook('knotx')
      template.source('knotx/logback.xml.erb')
      template.mode('0644')
      template.variables(
        main_log_level: node['knotx']['log_level']['main'],
        netty_log_level: node['knotx']['log_level']['netty'],
        root_log_level: node['knotx']['log_level']['root']
      )
      template.run_action(:create)
      template.updated_by_last_action?
    end

    def link_current_version(src, dst)
      link_name = ::File.join(dst, '/knotx.jar')
      link = Chef::Resource::Link.new(
        link_name,
        run_context
      )
      link.to(src)
      link.run_action(:create)
      link.updated_by_last_action?
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
