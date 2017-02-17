#
# Cookbook Name:: knotx
# Resource:: knotx_instance
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
#

class Chef
  class Resource
    class KnotxInstance < Chef::Resource
      provides :knotx_instance

      attr_accessor :installed
      attr_accessor :reconfigured
      attr_accessor :download_path
      attr_accessor :install_path
      attr_accessor :install_dir
      attr_accessor :app_config_path
      attr_accessor :app_config_extra
      attr_accessor :full_id
      attr_accessor :log_dir
      attr_accessor :checksum
      attr_accessor :source
      attr_accessor :filename

      # JVM opts
      attr_accessor :jvm_config_path
      attr_accessor :min_heap
      attr_accessor :max_heap
      attr_accessor :max_permsize
      attr_accessor :code_cache
      attr_accessor :extra_opts
      attr_accessor :jmx_ip
      attr_accessor :jmx_port
      attr_accessor :debug_port
      attr_accessor :port
      attr_accessor :jmx_enabled
      attr_accessor :debug_enabled

      # GIT opts
      attr_accessor :git_enabled
      attr_accessor :git_dir
      attr_accessor :git_url
      attr_accessor :git_user
      attr_accessor :git_pass
      attr_accessor :git_revision

      def initialize(id, run_context = nil)
        super

        @resource_name = :knotx_instance
        @allowed_actions = :install
        @action = :install

        @id = name
        @version = '1.0.0'
        @source = nil
        @install_dir = nil
        @log_dir = nil
      end

      def id(arg = nil)
        set_or_return(:id, arg, :kind_of => String)
      end

      def version(arg = nil)
        set_or_return(:version, arg, :kind_of => String)
      end

      def source(arg = nil)
        set_or_return(:source, arg, :kind_of => String)
      end

      def install_dir(arg = nil)
        set_or_return(:install_dir, arg, :kind_of => String)
      end

      def log_dir(arg = nil)
        set_or_return(:log_dir, arg, :kind_of => String)
      end
    end
  end
end
