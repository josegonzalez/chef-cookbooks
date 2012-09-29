package 'phpmyadmin' do
  action :upgrade
end

template "/etc/phpmyadmin/config.inc.php" do
  source "etc/phpmyadmin/config.inc.php.erb"
  owner "root"
  group "root"
  mode 0644
  action :create
end

link "/apps/phpmyadmin" do
  to "/usr/share/phpmyadmin"
  owner "deploy"
  group "deploy"
end
