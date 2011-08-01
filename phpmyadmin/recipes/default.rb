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

include_recipe "php"

directory "#{node[:server][:production][:dir]}/phpmyadmin" do
  owner "deploy"
  group "deploy"
  mode "0755"
  recursive true
end

remote_file "/tmp/phpmyadmin-#{node[:pma][:version]}.tar.gz" do
  owner "deploy"
  group "deploy"
  source "http://downloads.sourceforge.net/project/phpmyadmin/phpMyAdmin/#{node[:pma][:version]}/phpMyAdmin-#{node[:pma][:version]}-all-languages.tar.gz"
  checksum "#{node[:pma][:checksum]}"
  notifies :run, "script[phpmyadmin]", :immediately
  not_if do ::File.exists?("/tmp/phpmyadmin-#{node[:pma][:version]}.tar.gz") end
end

script "phpmyadmin" do
  action :run
  interpreter "bash"
  user "deploy"
  cwd "/tmp"
  code <<-EOH
  tar -C #{node[:server][:production][:dir]}/phpmyadmin -zxf /tmp/phpmyadmin-#{node[:pma][:version]}.tar.gz
  mv #{node[:server][:production][:dir]}/phpmyadmin/phpMyAdmin-#{node[:pma][:version]}-all-languages #{node[:server][:production][:dir]}/phpmyadmin/public
  EOH
  not_if do ::File.exists?("#{node[:server][:production][:dir]}/phpmyadmin/public") end
end

template "#{node[:nginx][:dir]}/sites-available/phpmyadmin" do
  source "phpmyadmin.erb"
  owner "deploy"
  group "deploy"
  mode 0644
end

nginx_site "phpmyadmin" do
  action :enable
end