directory "/data/mongodb" do
  owner "root"
  group "root"
  mode  0755
  recursive true
  action :create
  not_if { ::FileTest.directory?("/data") }
end

execute "touch /data/mongodb/.formatted" do
  command "touch /data/mongodb/.formatted"
  creates "/data/mongodb/.formatted"
end

# UID for mongodb should be 111
user "mongodb" do
  comment "MongoDB Server"
  home    "/data/mongodb"
  shell   "/bin/false"
  uid     111
  supports :manage_home => true
  action [ :create, :manage ]
end

link "/var/lib/mongodb" do
  to "/data/mongodb"
  not_if { ::FileTest.directory?("/var/lib/mongodb") }
end
