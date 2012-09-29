# Note: This user id starts at 1010 to avoid conflicts
#       with other admins adding users randomly.
user "deploy" do
  comment "Deploy User"
  home    "/home/deploy"
  shell   "/bin/bash"
  uid     1010
  supports :manage_home => true
  action [ :create, :manage ]
end

directory "/home/deploy/.ssh" do
  owner "deploy"
  group "deploy"
  mode 0755
  action :create
  not_if { File.exists? "/home/deploy/.ssh" }
end

# Add deploy private and public key for GitHub
template "/home/deploy/.ssh/id_rsa" do
  source "home/deploy/ssh/id_rsa.erb"
  owner "deploy"
  group "deploy"
  mode 0600
  action :create
  variables(
    :private_key => node['core']['users']['deploy']['private_key']
  )
end

template "/home/deploy/.ssh/id_rsa.pub" do
  source "home/deploy/ssh/id_rsa.pub.erb"
  owner "deploy"
  group "deploy"
  mode  0600
  action :create
  variables(
    :public_key => node['core']['users']['deploy']['public_key']
  )
end

# Set a custom ssh_config for the deploy user so we can ssh
# without having to accept a known_host
template "/home/deploy/.ssh/config" do
  source "home/deploy/ssh/config.erb"
  owner "deploy"
  group "deploy"
  mode 0600
  action :create
end

# Do the same for root
directory "/root/.ssh" do
  owner "root"
  group "root"
  mode 0755
  action :create
  not_if { File.exists? "/root/.ssh" }
end

template "/root/.ssh/id_rsa" do
  source "home/deploy/ssh/id_rsa.erb"
  owner "root"
  group "root"
  mode 0600
  action :create
  variables(
    :private_key => node['core']['users']['deploy']['private_key']
  )
end

template "/root/.ssh/id_rsa.pub" do
  source "home/deploy/ssh/id_rsa.pub.erb"
  owner "root"
  group "root"
  mode  0600
  action :create
  variables(
    :public_key => node['core']['users']['deploy']['public_key']
  )
end

# Set a custom ssh_config for the root user so we can ssh
# without having to accept a known_host
template "/root/.ssh/config" do
  source "home/deploy/ssh/config.erb"
  owner "root"
  group "root"
  mode 0600
  action :create
end

ssh_keys    = []

node['authorization']['deploy'].each_with_index do |u, i|
  user u['username'] do
    comment u['fullname']
    home    "/home/%s" % u['username']
    shell   "/bin/bash"
    uid     u['uid']
    supports :manage_home => true
    action [ :create, :manage ]
  end

  directory "/home/#{u['username']}/.ssh" do
    owner u['username']
    group u['username']
    mode 0755
    action :create
    not_if { File.exists? "/home/#{u['username']}/.ssh" }
  end

  template "/home/#{u['username']}/.ssh/authorized_keys" do
    source "home/deploy/ssh/authorized_keys.erb"
    variables(:keys => u['ssh_keys'])
    owner u['username']
    group u['username']
    mode 0600
    action :create
  end

  u['ssh_keys'].each {|key| ssh_keys << key }
end

# deploy use ssh key
ssh_keys << 'ssh-rsa ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDI0DMEA3Jlmii/cQEh9UanWVWUFOS8dIX8XRvAdrW/M7XwYUNyQRRBXpBt6MKaoTXIoIhldm0npHqWLaZ5A/ehLniDjQiyfUF3eSk3vXMbYbgedHQT2HtkwfD6vJd5Ef8FXMPvdKcFFOleHaacDu8k4hs9Gq19HQJ+uz8MZzYP7iUaSyWfrWMbG2xmUACKONxCPJG10LXPPIe2MpkB5olKie2CU7M4EHod8/qD3zeTdZSBhjg2cbNooMG44PMWlZqRLvSrLrZcqhuxD+wJnIemJbyOcYN0vXTqdCnpfSmYHN87+eFVpEd3qcC3eYGVoAnEKFQ1+17qkaXqDwTZ6RYd'

# Create an authorized key for every user we have for deploy
template "/home/deploy/.ssh/authorized_keys" do
  source "home/deploy/ssh/authorized_keys.erb"
  variables(:keys => ssh_keys)
  owner "deploy"
  group "deploy"
  mode 0600
  action :create
end

template "/etc/sudoers" do
  source "etc/sudoers.erb"
  mode 0440
  owner "root"
  group "root"
  variables(
    :sudoers_groups => node['authorization']['sudo']['groups'],
    :sudoers_users => node['authorization']['sudo']['users']
  )
end
