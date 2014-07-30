#
# Cookbook Name:: push-jobs
# Library:: helpers
#
# Author:: Joshua Timberman <joshua@getchef.com>
# Author:: Charles Johnson <charles@getchef.com>
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

require 'uri'
require 'chef/config'

module Opscode
  module PushJobs
    # Helper functions for Push Jobs cookbook
    module Helper
      include Chef::Mixin::Language if Chef::VERSION < '11.0.0'
      include Chef::DSL::PlatformIntrospection if Chef::VERSION >= '11.0.0'

      def package_file(url = 'http://www.opscode.com/chef/install.sh')
        uri = ::URI.parse(::URI.unescape(url))
        package_file = File.basename(uri.path)
        package_file
      end

      def config_path
        ::File.join(config_dir, 'push-jobs-client.rb')
      end

      def config_dir
        Chef::Config.platform_specific_path('/etc/chef')
      end

      def find_pushy_client
        if node['platform'] == 'windows'
          existence_check = :exists?
          # Where will also return files that have extensions matching PATHEXT (e.g.
          # *.bat). We don't want the batch file wrapper, but the actual script.
          which = 'set PATHEXT=.exe & where'
          Chef::Log.debug "Using exists? and 'where', since we're on Windows"
        else
          existence_check = :executable?
          which = 'which'
          Chef::Log.debug "Using executable? and 'which' since we're on Linux"
        end

        pushy_in_sane_path = lambda do
          begin
            Chef::Client::SANE_PATHS.map do |p|
              p = "#{p}/pushy-client"
              p if ::File.send(existence_check, p)
            end.compact.first
          rescue NameError
            false
          end
        end

        # try to use the bin provided by the node attribute
        if ::File.send(existence_check, node['push_jobs']['bin'])
          Chef::Log.debug 'Using pushy-client bin from node attributes'
          node['push_jobs']['bin']
        # search for the bin in some sane paths
        elsif Chef::Client.const_defined?('SANE_PATHS') && pushy_in_sane_path.call
          Chef::Log.debug 'Using pushy-client bin from sane path'
          pushy_in_sane_path
        # last ditch search for a bin in PATH
        elsif (pushy_in_path = %x{#{which} pushy-client}.chomp) && ::File.send(existence_check, pushy_in_path)
          Chef::Log.debug 'Using pushy-client bin from system path'
          pushy_in_path
        else
          fail "Could not locate the pushy-client bin in any known path. Please set the proper path by overriding the node['push_jobs']['bin'] attribute."
        end
      end
    end
  end
end
