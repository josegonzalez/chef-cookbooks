file "/etc/nginx/sites-enabled/default" do
  action :delete
end

file "/etc/nginx/sites-available/default" do
  action :delete
end

node['core']['nginx']['sites'].each do |site, config|
  nginx_site site do
    variables(config)
  end

  if config.key?('htpasswd_file')
    # Password file
    template "/etc/nginx/#{config['htpasswd_file']}.htpasswd" do
      source "etc/nginx/default.htpasswd.erb"
      owner "root"
      group "root"
      mode 0644
      action :create
      variables({
        :username => config['htpasswd']['username'],
        :encrypted => config['htpasswd']['encrypted']
      })
      notifies :reload, resources(:service => "nginx"), :delayed
      only_if { config.key?('htpasswd') }
    end
  end
end
