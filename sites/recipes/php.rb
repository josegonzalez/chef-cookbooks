include_recipe "apache2"
include_recipe "php"

folders = ["log", "private", "releases", "shared"]

cake_shared_folders = [
  "tmp", "tmp/cache", "tmp/logs", "tmp/repos", "tmp/sessions", "tmp/tests",
  "tmp/cache/data", "tmp/cache/models", "tmp/cache/persistent", "tmp/cache/views"
]

node[:php_applications].each do |hostname, sites|

  directory "#{node[:apache][:production][:dir]}/#{hostname}" do
      owner "deploy"
      group "deploy"
      mode "0755"
      recursive true
  end

  sites.each do |base, info|

    directory "#{node[:apache][:production][:dir]}/#{hostname}/#{base}" do
        owner "deploy"
        group "deploy"
        mode "0755"
        recursive true
    end

    folders.each do |folder|
      directory "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/#{folder}" do
          owner "deploy"
          group "deploy"
          mode "0755"
          recursive true
      end
    end

    link "cakephp_libraries_#{hostname}_#{base}" do
      to "#{node[:apache][:production][:dir]}/resources/#{info[:cake_version]}/cake"
      target_file "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/cake"
      owner "deploy"
      group "deploy"
      action :nothing
    end

    link "lithium_libraries #{hostname}_#{base}" do
      to "#{node[:apache][:production][:dir]}/resources/lithium/libraries"
      target_file "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/libraries"
      owner "deploy"
      group "deploy"
      action :nothing
    end

    directory "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config" do
        owner "deploy"
        group "deploy"
        mode "0755"
        recursive true
        action :nothing
        subscribes :create, resources(:link => "cakephp_libraries_#{hostname}_#{base}"), :immediately
    end

    cake_shared_folders.each do |folder|
      directory "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/#{folder}" do
          owner "deploy"
          group "deploy"
          mode "0777"
          recursive true
          action :nothing
          subscribes :create, resources(:link => "cakephp_libraries_#{hostname}_#{base}"), :immediately
      end
    end

    execute "tmp_permissions_#{hostname}_#{base}" do
      command "chmod -R 777 #{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/tmp"
      action :nothing
      subscribes :run, resources(:directory => "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/tmp"), :immediately
    end

    link "tmp_link_#{hostname}_#{base}" do
      to "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/tmp"
      target_file "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public/tmp"
      action :nothing
      subscribes :create, resources(:execute => "tmp_permissions_#{hostname}_#{base}"), :immediately
    end

    git "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public" do
      repository info[:repository]
      reference "HEAD"
      user "deploy"
      group "deploy"
      action :checkout
      notifies :create, resources(:link => "cakephp_libraries_#{hostname}_#{base}"), :immediately
    end

    execute "git_submodule_#{hostname}_#{base}" do
      command "cd #{node[:apache][:production][:dir]}/#{hostname}/#{base}/public && git submodule init && git submodule update"
      user "deploy"
      group "deploy"
      action :nothing
      subscribes :run, resources(:git => "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public"), :immediately
    end

    # bootstrap.php.erb
    link "cakephp_bootstrap" do
      to "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config/bootstrap.php"
      target_file "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public/config/bootstrap.php"
      owner "deploy"
      group "deploy"
      action :nothing
    end

    template "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config/bootstrap.php" do
      source "cakephp/bootstrap.php.erb"
      owner "deploy"
      group "deploy"
      mode 0644
      action :nothing
      notifies :create, resources(:link => "cakephp_bootstrap"), :immediately
      subscribes :create, resources(:link => "cakephp_libraries_#{hostname}_#{base}"), :immediately
    end

    # core.php.erb
    link "cakephp_core" do
      to "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config/core.php"
      target_file "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public/config/core.php"
      owner "deploy"
      group "deploy"
      action :nothing
    end

    template "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config/core.php" do
      source "cakephp/core.php.erb"
      owner "deploy"
      group "deploy"
      mode 0644
      variables(
        :debug                => "#{info[:variables][:debug]}",
        :cache_disable        => "#{info[:variables][:cache_disable]}",
        :session_save         => "#{info[:variables][:session_save]}",
        :security_salt        => "#{info[:variables][:security_salt]}",
        :security_cipher_seed => "#{info[:variables][:security_cipher_seed]}"
      )
      action :nothing
      notifies :create, resources(:link => "cakephp_core"), :immediately
      subscribes :create, resources(:link => "cakephp_libraries_#{hostname}_#{base}"), :immediately
    end

    # database.php.erb
    link "cakephp_database" do
      to "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config/database.php"
      target_file "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public/config/database.php"
      owner "deploy"
      group "deploy"
      action :nothing
    end

    template "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/shared/config/database.php" do
      source "cakephp/database.php.erb"
      owner "deploy"
      group "deploy"
      mode 0644
      variables(
        :login                => "#{info[:variables][:login]}",
        :password             => "#{info[:variables][:password]}",
        :database             => "#{info[:variables][:database]}"
      )
      action :nothing
      notifies :create, resources(:link => "cakephp_database"), :immediately
      subscribes :create, resources(:link => "cakephp_libraries_#{hostname}_#{base}"), :immediately
    end

    # Apache setup
    template "#{node[:apache][:dir]}/sites-available/#{hostname}.#{base}" do
      source "php.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :folder     => "/#{hostname}/#{base}/public/webroot",
        :nick       => "#{base}.#{hostname}",
        :hostname   => "#{hostname}",
        :subdomain  => "#{info[:subdomain]}",
        :resources  => [ "php", "html", "htm" ]
      )
    end

    apache_site "#{hostname}.#{base}" do
      action :enable
    end

  end
end