directory "/data/elasticsearch" do
  owner "root"
  group "root"
  mode  0755
  recursive true
  action :create
  not_if { ::FileTest.directory?("/data") }
end

execute "touch /data/elasticsearch/.formatted" do
  command "touch /data/elasticsearch/.formatted"
  creates "/data/elasticsearch/.formatted"
end

# UID for elasticsearch should be 110
user "elasticsearch" do
  comment "ElasticSearch Server"
  home    "/data/elasticsearch"
  shell   "/bin/false"
  uid     110
  supports :manage_home => true
  action [ :create, :manage ]
end

link "/var/lib/elasticsearch" do
  to "/data/elasticsearch"
  not_if { ::FileTest.directory?("/var/lib/elasticsearch") }
end
