redis_source_tarball = "redis-#{node['redis']['source']['version']}.tar.gz"
redis_source_url = "#{node['redis']['source']['url']}/#{redis_source_tarball}"

node['redis']['src_dir'] = "#{node['redis']['src_dir']}-#{node['redis']['source']['version']}"
node['redis']['dst_dir'] = "#{node['redis']['dst_dir']}-#{node['redis']['source']['version']}"

# Install Redis
%w[ src_dir dst_dir ].each do |dir|
  directory node['redis'][dir] do
    owner node['redis']['user']
    group node['redis']['group']
    action :create
  end
end

execute "install-redis" do
  cwd node['redis']['src_dir']
  command "make PREFIX=#{node['redis']['dst_dir']} install"
  creates "#{node['redis']['dst_dir']}/bin/redis-server"
  user node['redis']['user']
  action :nothing
end

execute "make-redis" do
  cwd node['redis']['src_dir']
  command "make"
  creates "redis"
  user node['redis']['user']
  action :nothing
  notifies :run, "execute[install-redis]", :immediately
end

execute "redis-extract-source" do
  command "tar zxf #{Chef::Config['file_cache_path']}#{redis_source_tarball} --strip-components 1 -C #{node['redis']['src_dir']}"
  creates "#{node['redis']['src_dir']}/COPYING"
  only_if do File.exist?("#{Chef::Config['file_cache_path']}#{redis_source_tarball}") end
  action :run
  notifies :run, "execute[make-redis]", :immediately
end

remote_file "#{Chef::Config['file_cache_path']}#{redis_source_tarball}" do
  source redis_source_url
  mode 0644
  checksum node['redis']['source']['sha']
  notifies :run, "execute[redis-extract-source]", :immediately
end

# Create required redis directories
directory node['redis']['conf_dir'] do
  owner "root"
  group "root"
  mode 0755
end

directory node['redis']['config']['dir'] do
  owner node['redis']['user']
  group node['redis']['group']
  mode 0755
end

template "#{node['redis']['conf_dir']}/redis.conf" do
  source "etc/redis/redis.conf.erb"
  owner "root"
  group "root"
  mode 0644
  variables node['redis']['config']
  notifies :restart, "service[redis]", :delayed
end

# Service
template "redis_init" do
  path "/etc/init.d/redis-server"
  source "etc/init.d/redis-server.erb"
  owner "root"
  group "root"
  mode 0755
end

service "redis" do
  service_name "redis-server"
  action [ :enable, :start ]
end

# Client
file "/usr/bin/redis-cli" do
  content "#{node['redis']['src_dir']}/src/redis-cli"
  provider Chef::Provider::File::Copy
  mode 0755
end
