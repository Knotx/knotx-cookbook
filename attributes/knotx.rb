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

default['knotx']['log_level']['main'] = 'INFO'
default['knotx']['log_level']['netty'] = 'INFO'
default['knotx']['log_level']['root'] = 'ERROR'

# Knotx source attributes
default['knotx']['release_url'] =
  'https://github.com/Cognifide/knotx/releases/download'

# JVM default parameters (those can be specifically overridden per instance)
#
# For example default['knotx']['main']['debug_enabled'] = true will override
# current setting for 'main' knotx instance.

default['knotx']['debug_enabled'] = false
default['knotx']['jmx_enabled'] = true

# JVM config file relative to instance root dir
default['knotx']['jvm_config_path'] = 'knotx.conf'

default['knotx']['jmx_ip'] = '0.0.0.0'
default['knotx']['jmx_port'] = '18092'
default['knotx']['debug_port'] = '28092'

default['knotx']['min_heap'] = '256'
default['knotx']['max_heap'] = '1024'
default['knotx']['code_cache'] = '64'
default['knotx']['extra_opts'] = ''
