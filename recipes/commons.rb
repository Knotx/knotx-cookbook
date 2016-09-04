#
# Cookbook Name:: knotx
# Recipe:: commons
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

# TODO: Consider if this is worth including in HWRP

include_recipe 'java::default'

group node['knotx']['group'] do
  system true
end

directory node['knotx']['base_dir'] do
  recursive true
end

user node['knotx']['user'] do
  comment 'Knotx User'
  gid node['knotx']['group']
  home node['knotx']['base_dir']
  shell '/bin/bash'
  supports manage_home: true
  system true
end
