#
# Cookbook Name:: knotx
# Libraries:: ConfigHelpers
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
  module ConfigHelpers
    require 'json'

    def get_attr(config_branch)
      # TODO: would be really nice to have recursion over here

      case config_branch
      when 'server_config'
        branch = %w(
          http.port
          preserved.headers
          dependencies
        )
      when 'repo_config'
        branch = %w(
          service.name
          repositories
        )
      when 'engine_config'
        branch = %w(
          service.name
          template.debug
          services
        )
      end

      # Assigning current config branch to temporary variable as we don't want
      # to operate directly on chef attributes
      config_hash = Hash[node['knotx'][config_branch]]

      branch.each do |var|
        config_hash[var] =
          node['knotx'][new_resource.id][config_branch][var] if
            node['knotx'].key?(new_resource.id) &&
            node['knotx'][new_resource.id].key?(config_branch) &&
            node['knotx'][new_resource.id][config_branch].key?(var)
      end

      config_hash
    end

    def generate_config
      # Initalize config root
      knotx_config = Hash[
        'server' =>
          Hash['config' => get_attr('server_config')],
        'repository' =>
          Hash['config' => get_attr('repo_config')],
        'engine' =>
          Hash['config' => get_attr('engine_config')]
      ]

      # Prettify and generate
      JSON.pretty_generate(knotx_config, indent: '  ')
    end
  end
end
