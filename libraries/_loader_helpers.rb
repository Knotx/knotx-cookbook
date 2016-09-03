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
    def load_jvm_vars
      %w(
        debug_enabled
        jmx_enabled
        jmx_ip
        jmx_port
        debug_port
        min_heap
        max_heap
        max_permsize
        code_cache
        extra_opts
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
  end
end
