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

# Server settings
default['knotx']['server_config']['http.port'] = 8092
default['knotx']['server_config']['allowed.response.headers'] = [
  'referer',
  'user-agent',
  'from',
  'content-type',
  'content-length',
  'accept-charset',
  'accept-encoding',
  'accept-language',
  'accept',
  'host',
  'if-match',
  'if-none-match',
  'if-range',
  'if-unmodified-since',
  'if-modified-since',
  'max-forwards',
  'proxy-authorization',
  'proxy-connection',
  'range',
  'cookie',
  'cq-action',
  'cq-handle',
  'handle',
  'action',
  'cqstats',
  'depth',
  'translate',
  'expires',
  'date',
  'dav',
  'ms-author-via',
  'if',
  'destination',
  'access-control-allow-origin',
  'x-original-requested-uri',
  'x-solr-core-key',
  'x-language-code',
  'x-requested-with',
  'location'
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
default['knotx']['server_config']['engine']['address'] = 'knotx.core.engine'

###############################################################################
# Repositories settings

# File repository
default['knotx']['http_repo_config']['address'] = 'knotx.core.repository.http'

# Using this style due to long config paths
default['knotx']['http_repo_config']['configuration'] = {
  'client.options' => {
    'maxPoolSize' => 1000,
    'keepAlive' => false,
    'tryUseCompression' => true
  },
  'client.destination' => {
    'domain' => '127.0.0.1',
    'port' => 80
  }
}

# HTTP repository
default['knotx']['file_repo_config']['address'] =
  'knotx.core.repository.filesystem'
default['knotx']['file_repo_config']['configuration']['catalogue'] = ''

###############################################################################
# Engine settings
default['knotx']['engine_config']['address'] = 'knotx.core.engine'
default['knotx']['engine_config']['template.debug'] = true
default['knotx']['engine_config']['client.options'] = {
  'maxPoolSize' => 1000,
  'keepAlive' => false
}
default['knotx']['engine_config']['services'] = [
  {
    'path' => '/service/.*',
    'domain' => 'localhost',
    'port' => 8080,
    'allowed.request.headers' => [
      'Content-Type',
      'X-*'
    ]
  }
]
