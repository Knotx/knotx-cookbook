#
# Cookbook Name:: knotx
# Recipe:: install
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

include_recipe 'knotx::commons'

# Nearly all settings (except logging ones) are derived either from default
# attributes or configuration files shipped with knotx-stack distribution
knotx_instance 'Primary knot.x instance' do
  id 'primary'
  source node['knotx']['url']
end

# Use attributes to overwrite default parameters
node.default['knotx']['secondary']['extra_opts'] = '-Dknotx.port=8093'
node.default['knotx']['secondary']['jmx_port'] = '18093'
node.default['knotx']['secondary']['debug_enabled'] = true
node.default['knotx']['secondary']['debug_port'] = '28093'
node.default['knotx']['secondary']['instance_opts'] = '-conf /opt/knotx/secondary/conf/bootstrap.json'

knotx_instance 'Secondary knot.x instance' do
  id 'secondary'
  source node['knotx']['url']
end
