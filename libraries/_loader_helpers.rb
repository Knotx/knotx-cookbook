#
# Cookbook Name:: knotx
# Libraries:: LoaderHelpers
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
  module LoaderHelpers
    def load_config_vars
      %w(
        jvm_config_path
        app_config_path
        app_config_extra
        debug_enabled
        jmx_enabled
        jmx_ip
        jmx_port
        jmx_security_enabled
        jmx_user
        jmx_password
        debug_port
        port
        min_heap
        max_heap
        code_cache
        extra_opts
        gc_opts
      ).each do |var|
        if node['knotx'].key?(new_resource.id) &&
           node['knotx'][new_resource.id].key?(var)
          @new_resource.send("#{var}=", node['knotx'][new_resource.id][var])
        else
          @new_resource.send("#{var}=", node['knotx'][var])
        end
        Chef::Log.debug("Value of #{var}: #{new_resource.send(var)}")
      end
    end

    def load_git_vars
      %w(
        git_enabled
        git_dir
        git_url
        git_user
        git_pass
        git_revision
      ).each do |var|
        if node['knotx'].key?(new_resource.id) &&
           node['knotx'][new_resource.id].key?('config') &&
           node['knotx'][new_resource.id]['config'].key?(var)
          @new_resource.send(
            "#{var}=",
            node['knotx'][new_resource.id]['config'][var]
          )
        else
          @new_resource.send("#{var}=", node['knotx']['config'][var])
        end
        Chef::Log.debug("Value of #{var}: #{new_resource.send(var)}")
      end
    end

    def load_source_vars
      %w(
        knotx_init_cookbook
        knotx_init_path
        knotx_systemd_cookbook
        knotx_systemd_path
        knotx_ulimit_cookbook
        knotx_ulimit_path
        knotx_conf_cookbook
        knotx_conf_path
        knotx_jvm_security_access_cookbook
        knotx_jvm_security_access_path
        knotx_jvm_security_password_cookbook
        knotx_jvm_security_password_path
        config_json_cookbook
        config_json_path
        logback_xml_cookbook
        logback_xml_path
      ).each do |var|
        if node['knotx'].key?(new_resource.id) &&
           node['knotx'][new_resource.id].key?('source') &&
           node['knotx'][new_resource.id]['source'].key?(var)
          @new_resource.send(
            "#{var}=",
            node['knotx'][new_resource.id]['source'][var]
          )
        else
          @new_resource.send("#{var}=", node['knotx']['source'][var])
        end
        Chef::Log.debug("Value of #{var}: #{new_resource.send(var)}")
      end
    end
  end
end
