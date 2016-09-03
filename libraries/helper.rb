#
# Cookbook Name:: knotx
# Libraries:: helper
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
  module Helper
    def parse_uri(addr, path)
      uri = escape_uri(addr + path)
      URI.parse(uri)
    rescue => e
      Chef::Application.fatal!("Invalid URI: #{e}")
    end

    def escape_uri(str)
      require 'addressable/uri'

      Addressable::URI.escape(str)
    rescue => e
      Chef::Application.fatal!("Unable to escape #{str}: #{e}")
    end

    def json_to_hash(str)
      require 'json'

      JSON.parse(str)
    rescue => e
      Chef::Application.fatal!("Unable to parse #{str} as JSON: #{e}")
    end

    def http_get(addr, path, user, password, timeout = 60)
      uri = parse_uri(addr, path)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = timeout
      http_req = Net::HTTP::Get.new(uri.request_uri)
      http_req.basic_auth(user, password)

      begin
        Chef::Log.debug("HTTP Request URI: #{uri.request_uri}")
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send GET request: #{e}")
      end
    end

    def url_basename(str)
      require 'pathname'
      require 'uri'

      Pathname.new(URI.parse(str).path).basename.to_s
    end

    def encode_credentials(user, pass)
      Base64.encode64("#{user}:#{pass}")
    end

    def http_auth_required?(user, pass)
      !(user.to_s == '') && !(pass.to_s == '')
    end

    def md5sum(filepath)
      Digest::MD5.file(filepath).hexdigest
    end

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
