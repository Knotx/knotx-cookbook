#
# Cookbook Name:: knotx
# Attributes:: knotx
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

# OS specific attributes
default['knotx']['user'] = 'knotx'
default['knotx']['group'] = 'knotx'
default['knotx']['base_dir'] = '/opt/knotx'
default['knotx']['log_dir'] = '/var/log/knotx'

# Knotx source attributes
default['knotx']['release_url'] =
  # 'https://github.com/Cognifide/knotx/releases/download'
  'https://github.com/karoldrazek/cookbook-knotx/releases/download'

# Knotx setup attributes (those can be specifically overridden per instance)
#
# For example default['knotx']['main']['server_config']['http.port'] = 123 will
# override current setting for 'main' knotx instance.

# TODO: add possibility to provide config in json form in single variable

# Server settings
default['knotx']['server_config']['http.port'] = 8092
default['knotx']['server_config']['preserved.headers'] = [
  'User-Agent',
  'X-Solr-Core-Key',
  'X-Language-Code'
]
default['knotx']['server_config']['dependencies']['repository.address'] =
  'template-repository'
default['knotx']['server_config']['dependencies']['engine.address'] =
  'template-engine'

# Repositories settings
default['knotx']['repo_config']['service.name'] = 'template-repository'
default['knotx']['repo_config']['repositories'] = [
  {
    'type' => 'local',
    'path' => '/content/local/.*',
    'catalogue' => ''
  },
  {
    'type' => 'remote',
    'path' => '/content/.*',
    'domain' => 'localhost',
    'part' => 3001
  }
]

# Engine settings
default['knotx']['engine_config']['service.name'] = 'template-engine'
default['knotx']['engine_config']['template-debug'] = true
default['knotx']['engine_config']['services'] = [
  {
    'path' => '/service/mock/.*',
    'domain' => 'localhost',
    'port' => 3000
  },
  {
    'path' => '/service/.*',
    'domain' => 'localhost',
    'port' => 8080
  }
]

# JVM default parameters (those can be specifically overridden per instance)
#
# For example default['knotx']['main']['debug_enabled'] = true will override
# current setting for 'main' knotx instance.

default['knotx']['debug_enabled'] = false
default['knotx']['jmx_enabled'] = true

default['knotx']['port'] = '8092'
default['knotx']['jmx_ip'] = '0.0.0.0'
default['knotx']['jmx_port'] = '18092'
default['knotx']['debug_port'] = '28092'

default['knotx']['min_heap'] = '256'
default['knotx']['max_heap'] = '1024'
default['knotx']['main']['max_heap'] = '524'
default['knotx']['max_permsize'] = '256'
default['knotx']['code_cache'] = '64'
default['knotx']['extra_opts'] = ''
