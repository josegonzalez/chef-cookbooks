directory "#{node[:server][:production][:dir]}/resources" do
  owner "deploy"
  group "deploy"
  mode "0755"
  recursive true
end

# CakePHP 1.3.X
git "#{node[:server][:production][:dir]}/resources/cakephp1.3" do
  repository "git://github.com/cakephp/cakephp.git"
  reference "9f583097f05fb78ef5958b98a0ef326b3ba3128f"
  user "deploy"
  group "deploy"
  action :checkout
end

# CakePHP 1.2.X
git "#{node[:server][:production][:dir]}/resources/cakephp1.2" do
  repository "git://github.com/cakephp/cakephp.git"
  reference "e6e50e88b284c3340628023ea2e0f62a3fe8f843"
  user "deploy"
  group "deploy"
  action :checkout
end

# Lithium 0.9.9
git "#{node[:server][:production][:dir]}/resources/lithium" do
  repository "git://github.com/josegonzalez/lithium.git"
  reference "HEAD"
  user "deploy"
  group "deploy"
  action :checkout
end

# Plugins
directory "#{node[:server][:production][:dir]}/resources/cakephp-plugins/" do
  owner "deploy"
  group "deploy"
  mode "0755"
  recursive true
end


node[:cakephp_plugins].each do |plugin, repo|
    folder = "#{node[:server][:production][:dir]}/resources/cakephp-plugins/" + plugin
    git folder do
      repository repo
      reference "HEAD"
      user "deploy"
      group "deploy"
      action :checkout
    end
end

# God PID
directory "/apps/pids" do
    owner "deploy"
    group "deploy"
    mode "0777"
    recursive true
    action :create
end
