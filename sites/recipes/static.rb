include_recipe "apache2"

node[:static_applications].each do |hostname, sites|

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

    git "#{node[:apache][:production][:dir]}/#{hostname}/#{base}/public" do
      repository info[:repository]
      reference "HEAD"
      user "deploy"
      group "deploy"
      action :sync
    end

    # Apache setup
    template "#{node[:apache][:dir]}/sites-available/#{hostname}.#{base}" do
      source "html.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :folder     => "/#{hostname}/#{base}/public#{info[:path]}",
        :nick       => "#{base}.#{hostname}",
        :hostname   => "#{hostname}",
        :subdomain  => "#{info[:subdomain]}",
        :resources  => [ "html", "htm" ]
      )
    end

    service "apache" do
      supports :restart => true, :reload => true
      action :nothing
    end

    apache_site "#{hostname}.#{base}" do
      action :enable
      notifies :run, resources(:service => "apache"), :immediately
    end
  
  end

end