#
# Cookbook Name:: push-jobs
# Recipe:: default
#
# Author:: Joshua Timberman <joshua@getchef.com>
# Author:: Charles Johnson <charles@getchef.com>
# Author:: Christopher Maier <cm@getchef.com>
# Copyright 2013-2014 Chef Software, Inc. <legal@getchef.com>
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

case node['platform_family']
when 'windows'
  unless (node['push_jobs']['package_url'] && node['push_jobs']['package_checksum'])
    raise "Please specify ['push_jobs']['package_url'] and ['push_jobs']['package_checksum'] attributes."
  end
end

unless (node['push_jobs']['whitelist'].is_a? Hash)
  raise "node['push_jobs']['whitelist'] should have a hash value!"
end

case node['platform_family']
when 'windows'
  include_recipe 'push-jobs::windows'
when 'debian', 'rhel'
  include_recipe 'push-jobs::linux'
else
  raise 'This cookbook currently supports only Windows, Debian-family Linux, and RHEL-family Linux.'
end
