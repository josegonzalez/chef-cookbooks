directory "/data/redis" do
  owner "root"
  group "root"
  mode  0755
  recursive true
  action :create
  not_if { ::FileTest.directory?("/data/redis") }
end

execute "touch /data/redis/.formatted" do
  command "touch /data/redis/.formatted"
  creates "/data/redis/.formatted"
end

# UID for redis should be 113
user "redis" do
  comment "Redis Server"
  home    "/data/redis"
  shell   "/bin/false"
  uid     113
  supports :manage_home => true
  action [ :create, :manage ]
end

link "/var/lib/redis" do
  to "/data/redis"
  not_if { ::FileTest.directory?("/var/lib/redis") }
end

directory "/var/log/redis" do
  owner "redis"
  group "redis"
  mode  0755
  recursive true
  action :create
  not_if { ::FileTest.directory?("/var/log/redis") }
end