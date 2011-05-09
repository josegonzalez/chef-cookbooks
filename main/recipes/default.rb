node[:base_packages].each do |pkg|
  package pkg do
    :upgrade
  end
end

node[:users].each_pair do |username, info|
  group username do
   gid info[:id] 
  end

  user username do 
    comment info[:full_name]
    uid info[:id]
    gid info[:id]
    shell info[:disabled] ? "/sbin/nologin" : "/bin/bash"
    home "/home/#{username}"
    supports :manage_home => true
    action [ :create, :manage ]
  end

  directory "/home/#{username}/.ssh" do
    owner username
    group username
    mode 0755
    action :create
    not_if { File.exists? "/home/#{username}/.ssh" }
  end

  # Add deploy private and public key for GitHub
  template "/home/#{username}/.ssh/id_rsa" do
    source "id_rsa.erb"
    owner username
    group username
    mode 0600
    action :create
    variables(
      :ssh_key => info[:private_key]
    )
  end

  file "/home/deploy/.ssh/id_rsa.pub" do
    owner username
    group username
    mode  0600
    action :create
    content info[:public_key]
  end

  file "/home/#{username}/.ssh/authorized_keys" do
    owner username
    group username
    mode 0600
    content info[:key]
  end

  # Set a custom ssh_config for the deploy user so we can ssh
  # without having to accept a known_host
  template "/home/#{username}/.ssh/config" do
    source "ssh_config.erb"
    owner username
    group username
    mode 0600
    action :create
  end

end

node[:groups].each_pair do |name, info|
  group name do
    gid info[:gid]
    members info[:members]
  end
end

template "/etc/sudoers" do
  source "sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers_groups => node[:authorization][:sudo][:groups],
    :sudoers_users => node[:authorization][:sudo][:users]
  )
end