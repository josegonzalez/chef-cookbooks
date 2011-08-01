node[:static_applications].each do |hostname, sites|

  directory "#{node[:server][:production][:dir]}/#{hostname}" do
      owner "deploy"
      group "deploy"
      mode "0755"
      recursive true
  end

  sites.each do |base, info|

    directory "#{node[:server][:production][:dir]}/#{hostname}/#{base}" do
        owner "deploy"
        group "deploy"
        mode "0755"
        recursive true
    end

    git "#{node[:server][:production][:dir]}/#{hostname}/#{base}/public" do
      repository info[:repository]
      reference "HEAD"
      user "deploy"
      group "deploy"
      action :sync
    end

    # Nginx site setup
    template "#{node[:nginx][:dir]}/sites-available/#{hostname}.#{base}" do
      source "nginx_html.erb"
      owner "root"
      group "root"
      mode 0644
      variables(
        :root     => "#{node[:server][:production][:dir]}/#{hostname}/#{base}/public#{info[:path]}",
        :nick       => "#{base}.#{hostname}",
        :hostname   => "#{hostname}",
        :subdomain  => "#{info[:subdomain]}",
        :resources  => [ "html", "htm" ]
      )
    end

    nginx_site "#{hostname}.#{base}" do
      action :enable
    end
  
  end

end