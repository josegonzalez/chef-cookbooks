include_recipe "php"

folders = ["log", "private", "releases", "shared"]

cake_shared_folders = [
  "config", "tmp", "tmp/cache", "tmp/logs", "tmp/repos", "tmp/sessions", "tmp/tests",
  "tmp/cache/data", "tmp/cache/models", "tmp/cache/persistent", "tmp/cache/views"
]

# Iterate over all the existing cakephp applications
node[:cakephp_applications].each do |hostname, sites|

  # Iterate over each site
  sites.each do |site_base, site_info|

    # Iterate over each environment
    node[:server].each do |environment, env_config|

      # Create both staging and production environments
      directory "#{env_config[:dir]}/#{hostname}/#{site_base}" do
          owner "deploy"
          group "deploy"
          mode "0755"
          recursive true
      end

      # Create all the hosting-related directories
      folders.each do |folder|
        directory "#{env_config[:dir]}/#{hostname}/#{site_base}/#{folder}" do
            owner "deploy"
            group "deploy"
            mode "0755"
            recursive true
        end
      end

      # Link the cakephp core
      link "cake_core_#{hostname}_#{site_base}_#{environment}" do
        to "#{env_config[:dir]}/resources/#{site_info[:cake_version]}/cake"
        target_file "#{env_config[:dir]}/#{hostname}/#{site_base}/cake"
        owner "deploy"
        group "deploy"
        action :nothing
      end

      # Create all the shared app directories
      cake_shared_folders.each do |folder|
        directory "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/#{folder}" do
            owner "deploy"
            group "deploy"
            mode "0777"
            recursive true
            action :nothing
            subscribes :create, resources(:link => "cake_core_#{hostname}_#{site_base}_#{environment}"), :immediately
        end
      end

      # Make the shared temporary directory writable
      execute "tmp_permissions_#{hostname}_#{site_base}_#{environment}" do
        command "chmod -R 777 #{env_config[:dir]}/#{hostname}/#{site_base}/shared/tmp"
        action :nothing
        subscribes :run, resources(:directory => "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/tmp"), :immediately
      end

      # Link in the shared directory to the public directory
      link "tmp_link_#{hostname}_#{site_base}_#{environment}" do
        to "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/tmp"
        target_file "#{env_config[:dir]}/#{hostname}/#{site_base}/public/tmp"
        action :nothing
        subscribes :create, resources(:execute => "tmp_permissions_#{hostname}_#{site_base}_#{environment}"), :immediately
      end

      # Clone the repository
      git "#{env_config[:dir]}/#{hostname}/#{site_base}/public" do
        repository site_info[:repository]
        reference "HEAD"
        user "deploy"
        group "deploy"
        action :checkout
        notifies :create, resources(:link => "cake_core_#{hostname}_#{site_base}_#{environment}"), :immediately
      end

      # Initialize the submodules
      execute "submodules_#{hostname}_#{site_base}_#{environment}" do
        command "cd #{env_config[:dir]}/#{hostname}/#{site_base}/public && git submodule init && git submodule update"
        user "deploy"
        group "deploy"
        action :nothing
        subscribes :run, resources(:git => "#{env_config[:dir]}/#{hostname}/#{site_base}/public"), :immediately
      end

      # Link the bootstrap.php
      link "app_bootstrap_#{hostname}_#{site_base}_#{environment}" do
        to "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/config/bootstrap.php"
        target_file "#{env_config[:dir]}/#{hostname}/#{site_base}/public/config/bootstrap.php"
        owner "deploy"
        group "deploy"
        action :nothing
      end

      # Link the core.php
      link "app_core_#{hostname}_#{site_base}_#{environment}" do
        to "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/config/core.php"
        target_file "#{env_config[:dir]}/#{hostname}/#{site_base}/public/config/core.php"
        owner "deploy"
        group "deploy"
        action :nothing
      end

      # database.php.erb
      link "app_database_#{hostname}_#{site_base}_#{environment}" do
        to "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/config/database.php"
        target_file "#{env_config[:dir]}/#{hostname}/#{site_base}/public/config/database.php"
        owner "deploy"
        group "deploy"
        action :nothing
      end

      # Create the app bootstrap.php
      template "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/config/bootstrap.php" do
        source "cakephp/bootstrap.php.erb"
        owner "deploy"
        group "deploy"
        mode 0644
        action :nothing
        notifies :create, resources(:link => "app_bootstrap_#{hostname}_#{site_base}_#{environment}"), :immediately
        subscribes :create, resources(:link => "cake_core_#{hostname}_#{site_base}_#{environment}"), :immediately
      end

      # Create the app core.php
      template "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/config/core.php" do
        source "cakephp/core.php.erb"
        owner "deploy"
        group "deploy"
        mode 0644
        variables(
          :debug                => site_info[:variables][environment][:debug],
          :cache_disable        => site_info[:variables][environment][:cache_disable],
          :session_save         => site_info[:variables][environment][:session_save],
          :security_salt        => site_info[:variables][environment][:security_salt],
          :security_cipher_seed => site_info[:variables][environment][:security_cipher_seed]
        )
        action :nothing
        notifies :create, resources(:link => "app_core_#{hostname}_#{site_base}_#{environment}"), :immediately
        subscribes :create, resources(:link => "cake_core_#{hostname}_#{site_base}_#{environment}"), :immediately
      end

      # Create the app database.php
      template "#{env_config[:dir]}/#{hostname}/#{site_base}/shared/config/database.php" do
        source "cakephp/database.php.erb"
        owner "deploy"
        group "deploy"
        mode 0644
        variables(
          :login                => site_info[:variables][environment][:login],
          :password             => site_info[:variables][environment][:password],
          :database             => site_info[:variables][environment][:database]
        )
        action :nothing
        notifies :create, resources(:link => "app_database_#{hostname}_#{site_base}_#{environment}"), :immediately
        subscribes :create, resources(:link => "cake_core_#{hostname}_#{site_base}_#{environment}"), :immediately
      end

      # Nginx setup
      template "#{node[:nginx][:dir]}/sites-available/#{hostname}.#{site_base}-#{environment}" do
        source "nginx_php.erb"
        owner "root"
        group "root"
        mode 0644
        variables(
          :folder_base=> "#{env_config[:dir]}/#{hostname}/#{site_base}",
          :root       => "#{env_config[:dir]}/#{hostname}/#{site_base}/public/webroot",
          :nick       => "#{site_base}.#{hostname}",
          :resources  => [ "php", "html", "htm" ],
          :hostname   => hostname,
          :subdomain  => site_info[:subdomain],
          :environment=> environment
        )
      end

      nginx_site "#{hostname}.#{site_base}-#{environment}" do
        action :enable
      end

    end

  end

end