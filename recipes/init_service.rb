# include helper methods
class ::Chef::Recipe
  include ::Opscode::PushJobs::Helper
end

#client_bin = find_pushy_client
#Chef::Log.debug("Found pushy-client in #{client_bin}")
#node.default['push_jobs']['bin'] = client_bin

dist_dir = value_for_platform_family(
  ['debian'] => 'debian',
  ['fedora'] => 'redhat',
  ['rhel'] => 'redhat',
  ['suse'] => 'suse'
)

template '/etc/init.d/push-jobs' do
  source "#{dist_dir}/init.d/push-jobs.erb"
  mode 00755
  variables :client_bin => node['push_jobs']['bin']
  notifies :restart, 'service[push-jobs]', :delayed
end

service 'push-jobs' do
  supports :status => true, :restart => true
  action [:enable, :start]
end
