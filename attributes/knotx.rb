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
default['knotx']['open_file_limit'] = '65536'

default['knotx']['log_level']['main'] = 'INFO'
default['knotx']['log_level']['root'] = 'ERROR'

default['knotx']['log_history']['main'] = '30'
default['knotx']['log_history']['root'] = '30'

# Knotx source attributes
default['knotx']['release_url'] =
  'https://oss.sonatype.org/content/groups/public/io/knotx/knotx-standalone'

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
default['knotx']['port'] = '8092'

default['knotx']['min_heap'] = '256'
default['knotx']['max_heap'] = '1024'
default['knotx']['code_cache'] = '64'
default['knotx']['extra_opts'] = ''
default['knotx']['gc_opts'] =
  '-XX:+UseConcMarkSweepGC -XX:ParallelGCThreads=2 -XX:ParallelCMSThreads=1'

# KNOTX CONFIG
default['knotx']['app_config_path'] = 'config.json'
default['knotx']['app_config_extra'] = ''

default['knotx']['config']['git_enabled'] = false
default['knotx']['config']['git_dir'] = nil
default['knotx']['config']['git_url'] =
  'https://github.com/Cognifide/knotx.git'
default['knotx']['config']['git_user'] = ''
default['knotx']['config']['git_pass'] = ''
default['knotx']['config']['git_revision'] = 'master'

# TEMPLATE SOURCES
default['knotx']['source']['knotx_init_cookbook'] = 'knotx'
default['knotx']['source']['knotx_init_path'] = 'etc/init.d/knotx.erb'

default['knotx']['source']['knotx_systemd_cookbook'] = 'knotx'
default['knotx']['source']['knotx_systemd_path'] =
  'etc/systemd/system/knotx.service.erb'

default['knotx']['source']['knotx_ulimit_cookbook'] = 'knotx'
default['knotx']['source']['knotx_ulimit_path'] =
  'etc/security/limits.d/knotx_limits.conf.erb'

default['knotx']['source']['knotx_conf_cookbook'] = 'knotx'
default['knotx']['source']['knotx_conf_path'] = 'knotx/knotx.conf.erb'

default['knotx']['source']['config_json_cookbook'] = 'knotx'
default['knotx']['source']['config_json_path'] = 'knotx/config.json'

default['knotx']['source']['logback_xml_cookbook'] = 'knotx'
default['knotx']['source']['logback_xml_path'] = 'knotx/logback.xml.erb'
