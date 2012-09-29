define :nginx_site, :enable => true, :variables => {}, :template => 'default' do
  if params[:enable]
    # Get our config file to the other side
    template "#{node['nginx']['dir']}/sites-available/#{params[:name]}" do
      source "site/#{params[:template]}.erb"
      owner "root"
      group "root"
      mode 0644
      variables(params[:variables])
    end

    # Enable
    execute "nxensite #{params[:name]}" do
      command "/usr/sbin/nxensite #{params[:name]}"
      notifies :reload, resources(:service => "nginx")
      not_if do File.symlink?("#{node['nginx']['dir']}/sites-enabled/#{params[:name]}") end
    end
  else
    execute "nxdissite #{params[:name]}" do
      command "/usr/sbin/nxdissite #{params[:name]}"
      notifies :reload, resources(:service => "nginx")
      only_if do File.symlink?("#{node['nginx']['dir']}/sites-enabled/#{params[:name]}") end
    end
  end
end
