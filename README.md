# knotx-cookbook

Cookbook that installs and knotx instance.

## Supported Platforms

* CentOS/RHEL 6.x
* CentOS/RHEL 7.x

## Attributes

### knotx.rb

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>default['knotx']['user']</tt></td>
    <td>String</td>
    <td>
      Knotx user
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['group']</tt></td>
    <td>String</td>
    <td>
      Knotx group
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['base_dir']</tt></td>
    <td>String</td>
    <td>
      Common installation directory
    </td>
    <td><tt>/opt/knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['open_file_limit']</tt></td>
    <td>String</td>
    <td>
      File descript limit for knotx user
    </td>
    <td><tt>65536</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['log_dir']</tt></td>
    <td>String</td>
    <td>
      Logging directory
    </td>
    <td><tt>/var/log/knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['log_level']['main']</tt></td>
    <td>String</td>
    <td>
      Main logging level
    </td>
    <td><tt>INFO</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['log_level']['root']</tt></td>
    <td>String</td>
    <td>
      Root logging level
    </td>
    <td><tt>ERROR</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['log_history']['main']</tt></td>
    <td>String</td>
    <td>
      Days how long main knotx logs should be kept
    </td>
    <td><tt>30</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['log_history']['root']</tt></td>
    <td>String</td>
    <td>
      Days how long root knotx logs should be kept
    </td>
    <td><tt>30</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['release_url']</tt></td>
    <td>String</td>
    <td>
      Base of download link used when only knotx version is provided
    </td>
    <td><tt>https://github.com/Cognifide/knotx/releases/download</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['debug_enabled']</tt></td>
    <td>Boolean</td>
    <td>
      Enable debug on dedicated port
    </td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jmx_enabled']</tt></td>
    <td>Boolean</td>
    <td>
      Enable JMX on dedicated port
    </td>
    <td><tt>true</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jmx_authorization_enabled']</tt></td>
    <td>Boolean</td>
    <td>
      Enable JMX user/password authorization
    </td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jmx_user']</tt></td>
    <td>String</td>
    <td>
      Username for JMX authorization
    </td>
    <td><tt>admin</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jmx_password']</tt></td>
    <td>String</td>
    <td>
      Password for JMX authorization
    </td>
    <td><tt>admin</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jvm_config_path']</tt></td>
    <td>String</td>
    <td>
      Path to JVM config relative to instance install directory
    </td>
    <td><tt>knotx.conf</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jmx_ip']</tt></td>
    <td>String</td>
    <td>
      JMX IP
    </td>
    <td><tt>0.0.0.0</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['jmx_port']</tt></td>
    <td>String</td>
    <td>
      JMX port
    </td>
    <td><tt>18092</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['debug_port']</tt></td>
    <td>String</td>
    <td>
      Debug port
    </td>
    <td><tt>28092</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['port']</tt></td>
    <td>String</td>
    <td>
      Knotx instance port
    </td>
    <td><tt>8092</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['min_heap']</tt></td>
    <td>String</td>
    <td>
      JVM minimum heap size
    </td>
    <td><tt>256</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['max_heap']</tt></td>
    <td>String</td>
    <td>
      JVM maximum heap size
    </td>
    <td><tt>1024</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['code_cache']</tt></td>
    <td>String</td>
    <td>
      JVM code cache size
    </td>
    <td><tt>64</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['extra_opts']</tt></td>
    <td>String</td>
    <td>
      JVM additional options
    </td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['gc_opts']</tt></td>
    <td>String</td>
    <td>
      Base garbage collection settings
    </td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['app_config_path']</tt></td>
    <td>String</td>
    <td>
      Path to knotx application config relative to instance install directory
    </td>
    <td><tt>config.json</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['app_config_extra']</tt></td>
    <td>String</td>
    <td>
      Additonal knotx startup paramters, for exmaple path to additonal extension
    </td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['config']['git_enabled']</tt></td>
    <td>String</td>
    <td>
      If true, then configuration is pulled from git to 'config' directory residing in instance directory
    </td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['config']['git_dir']</tt></td>
    <td>String</td>
    <td>
      Directory where git config should be cloned
    </td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['config']['git_url']</tt></td>
    <td>String</td>
    <td>
      URL to git repository with config
    </td>
    <td><tt>https://github.com/Cognifide/knotx.git</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['config']['git_user']</tt></td>
    <td>String</td>
    <td>
      User to access git repository
    </td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['config']['git_pass']</tt></td>
    <td>String</td>
    <td>
      Password to access git repository
    </td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['config']['git_revision']</tt></td>
    <td>String</td>
    <td>
      Revision, tag or branch name to pull from git repository
    </td>
    <td><tt>master</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_init_cookbook']</tt></td>
    <td>String</td>
    <td>
      Source cookbook for knotx init script template
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_init_path']</tt></td>
    <td>String</td>
    <td>
      Template path for knotx init script
    </td>
    <td><tt>etc/init.d/knotx.erb</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_systemd_cookbook']</tt></td>
    <td>String</td>
    <td>
      Source cookbook for knotx systemd script template
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_systemd_path']</tt></td>
    <td>String</td>
    <td>
      Template path for knotx systemd script
    </td>
    <td><tt>etc/systemd/system/knotx.service.erb</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_ulimit_cookbook']</tt></td>
    <td>String</td>
    <td>
      Source cookbook for knotx ulimit template
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_ulimit_path']</tt></td>
    <td>String</td>
    <td>
      Template path for knotx ulimit
    </td>
    <td><tt>etc/security/limits.d/knotx_limitx.conf.erb</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_conf_cookbook']</tt></td>
    <td>String</td>
    <td>
      Source cookbook for knotx.conf template
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['knotx_conf_path']</tt></td>
    <td>String</td>
    <td>
      Template path for knotx.conf file
    </td>
    <td><tt>knotx/knotx.conf.erb</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['config_json_cookbook']</tt></td>
    <td>String</td>
    <td>
      Source cookbook for config.json file
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['config_json']['path']</tt></td>
    <td>String</td>
    <td>
      Template path for config.json file
    </td>
    <td><tt>knotx/config.json</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['logback_xml_cookbook']</tt></td>
    <td>String</td>
    <td>
      Source cookbook for logback.xml template
    </td>
    <td><tt>knotx</tt></td>
  </tr>
  <tr>
    <td><tt>default['knotx']['source']['logback_xml_path']</tt></td>
    <td>String</td>
    <td>
      Template path for logback.xml file
    </td>
    <td><tt>knotx/logback.xml.erb</tt></td>
  </tr>
</table>

### knotx_instance resource attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>id</tt></td>
    <td>String</td>
    <td>
      Isntance ID. Used to create init scripts, instance directory and logfiles
    </td>
    <td><tt>Value of resoruce name</tt></td>
  </tr>
  <tr>
    <td><tt>version</tt></td>
    <td>String</td>
    <td>
      Which version of knotx should be deployed
    </td>
    <td><tt>1.0.1</tt></td>
  </tr>
  <tr>
    <td><tt>source</tt></td>
    <td>String</td>
    <td>
      Direct link to knotx jar that should be deployed. It overwrites 'version' attrbiute
    </td>
    <td><tt></tt></td>
  </tr>
</table>

## Instance specific attributes

In case we want to create second instance of knotx on the same server
named 'main2' we can just define instance specific atrributes that will
overwrite the default ones.

```ruby
default['knotx']['main2']['jmx_port'] = '18093'
default['knotx']['main2']['debug_port'] = '28093'
default['knotx']['main2']['port'] = '8093'
```

## Usage scenarios

Simple installation

```ruby
include_recipe 'knotx::commons'

knotx_instance 'Knotx Main: Install' do
  id 'main'
  version '1.0.0-RC2'
end
```

Installation with knotx extensions (automated installation is comming...)

```ruby
include_recipe 'knotx::commons'

base_dir = "#{node['knotx']['base_dir']}/main/app"

directory base_dir do
  owner node['knotx']['user']
  group node['knotx']['group']
  mode '0755'
  recursive true
  action :create
end

remote_file "#{base_dir}/knotx-ext.jar" do
  source "https://remotelink.com/knotx-ext.jar"
  owner node['knotx']['user']
  group node['knotx']['group']
  mode '0755'
  action :create

  notifies :restart, 'service[knotx-main]', :delayed
end

knotx_instance 'Knotx Main: Install' do
  id 'main'
  version '1.0.0-RC2'
end

service 'knotx-main' do
  action :nothing
end

```

## Work in progress ##

TODO:
* extensions installation
* further improve logic in HWRP
* switch between core and example possible
* jar cleanup after version switch
* all actions including restart/start/stop
* add extensions testing with multiple knotx instances

