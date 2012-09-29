include_recipe "percona::keys"

package "percona-server-common-5.5" do
  action :install
end

package "percona-server-server-5.5" do
  action :install
end

package "xtrabackup" do
  action :upgrade
end

service "mysql" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

template "/etc/mysql/my.cnf" do
  source "etc/mysql/my.cnf.erb"
  variables :mysql => node['mysql']
end
