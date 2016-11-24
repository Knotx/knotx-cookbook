#
# Cookbook Name:: knotx
# Attributes:: knotx_config
#
# Copyright 2016 Karol Drazek
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Knotx setup attributes (those can be specifically overridden per instance)
#
# For example default['knotx']['main']['server_config']['http.port'] = 123 will
# override current setting for 'main' knotx instance.

# TODO: add possibility to provide config in json form in single variable

# Knotx app config file relative to instance root dir
default['knotx']['app_config_path'] = 'config.json'
default['knotx']['app_config_extra'] = ''

default['knotx']['config']['git_enabled'] = false
default['knotx']['config']['git_url'] =
  'https://github.com/Cognifide/knotx.git'
default['knotx']['config']['git_user'] = ''
default['knotx']['config']['git_pass'] = ''
default['knotx']['config']['git_revision'] = 'master'

# Server settings
default['knotx']['server_config']['http.port'] = 8092
default['knotx']['server_config']['allowed.response.headers'] = [
  '*'
]

default['knotx']['server_config']['repositories'] = [
  {
    'path' => '/localfile/.*',
    'address' => 'knotx.core.repository.filesystem'
  },
  {
    'path' => '/.*',
    'address' => 'knotx.core.repository.http'
  }
]
default['knotx']['server_config']['splitter']['address'] = 'knotx.core.splitter'

default['knotx']['server_config']['routing'] = {
  'GET' => [
    {
      'path' => '/content/.*',
      'address' => 'knotx.knot.view'
    }
  ]
}

###############################################################################
# Repositories settings

# HTTP repository
default['knotx']['http_repo_config']['address'] = 'knotx.core.repository.http'

# Using this style due to long config paths
default['knotx']['http_repo_config']['client.options'] = {
  'maxPoolSize' => 1000,
  'keepAlive' => false,
  'tryUseCompression' => true
}

default['knotx']['http_repo_config']['client.destination'] = {
  'domain' => '127.0.0.1',
  'port' => 80
}

default['knotx']['http_repo_config']['allowed.request.headers'] = [
  '*'
]

# File repository
default['knotx']['file_repo_config']['address'] =
  'knotx.core.repository.filesystem'
default['knotx']['file_repo_config']['catalogue'] = ''

###############################################################################
# Splitter settings
default['knotx']['splitter_config']['address'] = 'knotx.core.splitter'

###############################################################################
# View settings
default['knotx']['view_config']['address'] = 'knotx.knot.view'
default['knotx']['view_config']['template.debug'] = true
default['knotx']['view_config']['client.options'] = {
  'maxPoolSize' => 1000,
  'keepAlive' => false
}
default['knotx']['view_config']['services'] = [
  {
    'path' => '/service/.*',
    'domain' => 'localhost',
    'port' => 8080,
    'allowed.request.headers' => [
      '*'
    ]
  }
]

###############################################################################
# Action settings
default['knotx']['action_config']['address'] = 'knotx.knot.action'
default['knotx']['action_config']['formIdentifierName'] = '_frmId'
default['knotx']['action_config']['adapters'] = [
  {
    'name' => 'step1',
    'address' => 'knotx.adapter.action.http',
    'params' => {
      'path' => '/service/mock/post-step-1.json'
    },
    'allowed.request.headers' => [
      '*'
    ],
    'allowed.response.headers' => [
      '*'
    ]
  }
]

###############################################################################
# Adapter settings
default['knotx']['adapter_config']['address'] = 'knotx.adapter.service.http'
default['knotx']['adapter_config']['client.options'] = {
  'maxPoolSize' => 1000,
  'keepAlive' => false,
  'logActivity' => true
}
default['knotx']['adapter_config']['services'] = [
  {
    'path' => '/service/.*',
    'domain' => 'localhost',
    'port' => 8080,
    'allowed.request.headers' => [
      '*'
    ]
  }
]
