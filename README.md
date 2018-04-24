# knotx-cookbook

This cookbook installs [knot.x](http://knotx.io/)

# Table of contents

* [Supported platforms](#supported-platforms)
    * [Operating systems](#operating-systems)
    * [Chef versions](#chef-versions)
    * [knot.x versions](#knotx-versions)
* [Attributes](#attributes)
    * [knotx.rb](#knotxrb)
    * [commons.rb](#commonsrb)
* [Custom resources](#custom-resources)
    * [knotx_instance](#knotx_instance)
        * [Properties](#properties)
        * [Customizations](#customizations)
* [Usage scenarios](#usage-scenarios)
    * [Simple installation](#simple-installation)
    * [Multiple instances](#multiple-instances)
* [Work in progress](#work-in-progress)

# Supported platforms

## Operating systems

* CentOS/RHEL 6.x
* CentOS/RHEL 7.x

## Chef versions

* Chef 13.x
* Chef 14.x

## knot.x versions

---

**IMPORTANT**

If you're using knot.x 1.1.x or 1.2.x please stick to 0.4.x version of this
cookbook!

---

* knot.x 1.3.x

# Attributes

## knotx.rb

* `['knotx']['user']` - user that runs knot.x service
* `['knotx']['group']` - group that owns knot.x service
* `['knotx']['base_dir']` - top level installation directory for all knot.x
  instance
* `['knotx']['log_dir']` - top level log directory for all knot.x instances
* `['knotx']['open_file_limit']`- number of maximum file descriptors service
  user can open
* `['knotx']['log_level']['root']` - default log level for all knot.x modules
* `['knotx']['log_level']['knotx']` - log level for `io.knotx` modules
* `'knotx']['log_history']['knotx']` - maximum age (in days) for knot.x logs
* `'knotx']['log_history']['access']` - maximum age (in days) for knot.x access
  log
* `['knotx']['log_size']['knotx']` - maximum file size of knot.x log file 
* `['knotx']['log_size']['access']` - maximum file size of knot.x access log
  file
* `['knotx']['release_url']` - base URL used to calculate download URL when
  only version was specified
* `'knotx']['min_heap']` - `-Xms` JVM parameter (in MB) 
* `'knotx']['max_heap']` - `-Xmx` JVM parameter (in MB)
* `['knotx']['extra_opts']` - custom JVM parameters you'd like to add upon
  service start
* `['knotx']['gc_opts']` - Garbage Collector JVM options
* `['knotx']['jmx_enabled']` - defines whether JMX should be enabled or not
* `['knotx']['jmx_ip']` - IP on which JMX interface should listen on
* `['knotx']['jmx_port']` - port of JMX interface
* `['knotx']['debug_enabled']` - defines whether JVM debugging interface is
  enabled or not
* `['knotx']['debug_port']` - port of JVM debug interface
* `['knotx']['source']['knotx_init_cookbook']` - cookbook where SysVinit script
  is located
* `['knotx']['source']['knotx_init_path']` path under `templates` where
  SysVinit script is located
* `['knotx']['source']['knotx_systemd_cookbook']` - cookbook where systemd unit
  file is located
* `['knotx']['source']['knotx_systemd_path']` - path under `templates` where
  systemd unit file is located
* `['knotx']['source']['knotx_ulimit_cookbook']` - cookbook where ulimit
  template file is located
* `['knotx']['source']['knotx_ulimit_path']` - path under `tamplates` where
  ulimit file is placed
* `['knotx']['source']['knotx_conf_cookbook']` - cookbook where knot.x JVM
  settings file is placed
* `['knotx']['source']['knotx_conf_path']` - path to knot.x JVM template within
  a cookbook
* `['knotx']['source']['logback_xml_cookbook']` - cookbook where `logback.xml`
  template is placed
* `['knotx']['source']['logback_xml_path']` - path to `logback.xml` template
  within a cookbook

## commons.rb

Attributes from [java](https://supermarket.chef.io/cookbooks/java) cookbook

# Custom resources

## knotx_instance

### Properties

* `id` - knot.x instance ID (derived from resource name by default)
* `version` - knot.x version to deploy (uses `['knotx']['release_url']` to
  calculate download URL)
* `source` - full URL to knot.x ZIP distribution package. Overwrites `version`
* `install_dir` - where knot.x instance should be deployed. If not set, knot.x
  gets deployed to `['knotx']['base_dir']/ID` directory 
* `log_dir` - directory where all logs will be stored. If not set logs are
  written to `['knotx']['log_dir']/ID` directory
* `custom_logback` - `logback.xml` used to be delivered with ZIP distribution
  package, however most of the time this is not what you want, as stdout is
  commonly used as an output. This property accepts boolean values (`true` by
  default) and generates `logback.xml` according to attributes

### Customizations

It is possible to deploy more than 1 knot.x instance on a single server. To set
that up you must ensure that each instance has unique ID and there's no
conflicting port assignments.

Instance specific properties can be set using special attribute convention.
Attributes defined this way overwrite the ones without ID in the name. See
example below for more details:

```ruby
# If none of below attributes is defined the following ones will be used:
# * default['knotx']['jmx_port']
# * default['knotx']['debug_port']
# * default['knotx']['port']
default['knotx']['main2']['jmx_port'] = '18093'
default['knotx']['main2']['debug_port'] = '28093'
default['knotx']['main2']['port'] = '8093'
```

The following attributes can be set this way:
* `node['knotx'][ID]['min_heap']`
* `node['knotx'][ID]['max_heap']`
* `node['knotx'][ID]['extra_opts']`
* `node['knotx'][ID]['gc_opts']`
* `node['knotx'][ID]['jmx_enabled']`
* `node['knotx'][ID]['jmx_ip']`
* `node['knotx'][ID]['jmx_port']`
* `node['knotx'][ID]['debug_enabled']`
* `node['knotx'][ID]['debug_port']`

# Usage scenarios

## Simple installation

```ruby
include_recipe 'knotx::commons'

knotx_instance 'Knotx Main: Install' do
  id 'main'
  version '1.0.0-RC2'
end
```

## Multiple instances

```ruby
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

knotx_instance 'Secondary knot.x instance' do
  id 'secondary'
  source node['knotx']['url']
end
```

# Work in progress

TODO:
* extensions installation
* further improve logic in HWRP
* switch between core and example possible
* jar cleanup after version switch
* all actions including restart/start/stop
* add extensions testing with multiple knotx instances

