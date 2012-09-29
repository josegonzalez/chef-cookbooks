package "postfix" do
  action :upgrade
end

service "postfix" do
  action :enable
  supports :restart => true, :reload => true
end

template "/etc/postfix/main.cf" do
  source "etc/postfix/main.cf.erb"
  mode 00644
  notifies :restart, resources(:service => "postfix")
end

service "postfix" do
  action :start
end
