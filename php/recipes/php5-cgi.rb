package "php5-cgi" do
  action :upgrade
end

service "php5-fastcgi" do
  supports :status => true, :restart => true
  action :nothing
end

template "/etc/default/php5-fastcgi" do
  source "etc/default/php5-fastcgi.erb"
  owner "root"
  group "root"
  mode 0644
  notifies [ :enable, :restart ], resources(:service => "php5-fastcgi")
end

template "/etc/init.d/php5-fastcgi" do
  source "etc/init.d/php5-fastcgi.erb"
  owner "root"
  group "root"
  mode 0755
  notifies [ :enable, :restart ], resources(:service => "php5-fastcgi")
end

template "/etc/php5/cgi/php.ini" do
  source "etc/php5/cgi/php.ini.erb"
  owner "root"
  group "root"
  mode 0644
  notifies [ :enable, :restart ], resources(:service => "php5-fastcgi")
end
