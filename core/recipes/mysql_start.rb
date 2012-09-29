directory "/data/mysql" do
  owner "root"
  group "root"
  mode  0755
  recursive true
  action :create
  not_if { ::FileTest.directory?("/data/mysql") }
end

execute "touch /data/mysql/.formatted" do
  command "touch /data/mysql/.formatted"
  creates "/data/mysql/.formatted"
end

# UID for mysql should be 112
user "mysql" do
  comment "MySQL Server"
  home    "/data/mysql"
  shell   "/bin/false"
  uid     112
  supports :manage_home => true
  action [ :create, :manage ]
end

link "/var/lib/mysql" do
  to "/data/mysql"
  not_if { ::FileTest.directory?("/var/lib/mysql") }
end

directory "/var/lib/mysql/binlogs" do
  owner "mysql"
  group "mysql"
  mode 0755
  recursive true
end
