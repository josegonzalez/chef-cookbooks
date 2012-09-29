if node['box_name']
  execute "hostname" do
    command "echo %s > /etc/hostname && hostname -F /etc/hostname" % node['box_name']
    not_if "hostname | grep -q %s" % node['box_name']
    action :run
  end
end
