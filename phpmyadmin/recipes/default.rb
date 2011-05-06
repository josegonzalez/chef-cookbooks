#
# Cookbook Name:: phpmyadmin
# Recipe:: default
#
# Copyright 2010, Example Com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

include_recipe "apache2"
include_recipe "php"

directory "#{node[:apache][:production][:dir]}/phpmyadmin" do
  owner "deploy"
  group "deploy"
  mode "0755"
  recursive true
end

script "phpmyadmin" do
  action :nothing
  interpreter "bash"
  user "deploy"
  cwd "/tmp"
  code <<-EOH
  tar -C #{node[:apache][:production][:dir]}/phpmyadmin -zxf /tmp/phpmyadmin-#{node[:pma][:version]}.tar.gz
  mv #{node[:apache][:production][:dir]}/phpmyadmin/phpMyAdmin-#{node[:pma][:version]}-all-languages #{node[:apache][:production][:dir]}/phpmyadmin/public
  EOH
end

remote_file "/tmp/phpmyadmin-#{node[:pma][:version]}.tar.gz" do
  owner "deploy"
  group "deploy"
  source "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/#{node[:pma][:version]}/phpMyAdmin-#{node[:pma][:version]}-all-languages.tar.gz"
  checksum "#{node[:pma][:checksum]}"
  notifies :run, resources(:script => "phpmyadmin"), :immediately
end

template "#{node[:apache][:dir]}/sites-available/phpmyadmin" do
  source "phpmyadmin.erb"
  owner "deploy"
  group "deploy"
  mode 0644
end

apache_site "phpmyadmin" do
  action :enable
end