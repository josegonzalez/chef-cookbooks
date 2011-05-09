#
# Cookbook Name:: god
# Recipe:: default
#
# Copyright 2011, SeatGeek, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

gem_package "god" do
  action :install
end

directory "/etc/god/conf.d" do
  recursive true
  owner "root"
  group "root"
  mode 0755
end

template "/etc/god/master.god" do
  source "master.god.erb"
  owner "root"
  group "root"
  mode 0755
end

cookbook_file "/etc/init.d/god" do
  source "god-init"
  owner "root"
  group "root"
  mode 0755
end

link "/usr/local/bin/god" do
  to "/var/lib/gems/1.8/bin/god"
  target_file "/usr/local/bin/god"
  owner "root"
  group "root"
end

service "god" do
  supports :status => true, :restart => true, :reload => true
  action [ :enable, :start ]
end
