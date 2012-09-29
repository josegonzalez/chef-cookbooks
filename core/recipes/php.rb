include_recipe "php::php5-cgi"
include_recipe "php::php5"
include_recipe "php::module_apc"
include_recipe "php::module_curl"
include_recipe "php::module_gd"
include_recipe "php::module_mysql"

# Properly configure apc
template "/etc/php5/conf.d/apc.ini" do
  source "etc/php5/conf.d/apc.ini.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end