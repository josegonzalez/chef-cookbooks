##
# Adds a host entry for every machine we have, speeding up DNS
# Unfortunately this is manual and not auto based on the DNA we have
template "/etc/hosts" do
  source "etc/hosts.erb"
  owner "root"
  group "root"
  mode  0644
  variables(:hosts => node['core']['hosts']['hosts'])
  action :create
end

package "snmpd" do
  action :install
end

service "snmpd" do
  action :enable
end

template "/etc/snmp/snmpd.conf" do
  source "etc/snmp/snmpd.conf.erb"
  owner "root"
  group "root"
  mode  0600
  notifies :restart, resources(:service => "snmpd")
end

template "/etc/default/snmpd" do
  source "etc/default/snmpd.erb"
  owner "root"
  group "root"
  mode  0600
  notifies :restart, resources(:service => "snmpd")
end