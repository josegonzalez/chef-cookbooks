define :logrotate, :path => false, :box_name => false, :role => false do
  unless params[:path]
    Chef::Log.info("No path for logrotate file set")
  else
    if params[:box_name]
      template params[:name] do
        source 'etc/logrotate.d/generic.conf.erb'
        owner 'root'
        group 'root'
        variables(:path => params[:path])
        mode 0644
        only_if { node['box_name'] =~ /#{params[:box_name]}/ }
      end
    elsif params[:roles]
      template params[:name] do
        source 'etc/logrotate.d/generic.conf.erb'
        owner 'root'
        group 'root'
        variables(:path => params[:path])
        mode 0644
        only_if { node[:roles].include?(params[:role]) }
      end
    else
      template params[:name] do
        source 'etc/logrotate.d/generic.conf.erb'
        owner 'root'
        group 'root'
        variables(:path => params[:path])
        mode 0644
      end
    end
  end
end

