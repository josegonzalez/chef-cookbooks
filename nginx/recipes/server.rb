package "nginx" do
  action :upgrade
end

service "nginx" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

directory node['nginx']['log_dir'] do
  mode 0755
  owner node['nginx']['user']
  action :create
end

%w{nxensite nxdissite}.each do |nxscript|
  template "/usr/sbin/#{nxscript}" do
    source "usr/sbin/#{nxscript}.erb"
    mode 0755
    owner "root"
    group "root"
  end
end

template "nginx.conf" do
  path "#{node['nginx']['dir']}/nginx.conf"
  source "etc/nginx/nginx.conf.erb"
  owner "root"
  group "root"
  mode 0644
  notifies :restart, resources(:service => "nginx"), :immediately
end

template "#{node['nginx']['dir']}/mime.types" do
  source "etc/nginx/mime.types.erb"
  owner "root"
  group "root"
  mode "0644"
  notifies :restart, resources(:service => "nginx"), :immediately
end
