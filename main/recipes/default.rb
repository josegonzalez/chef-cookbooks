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
        supports :manage_home => true
        home "/home/#{username}"
    end

    directory "/home/#{username}/.ssh" do
        owner username
        group username
        mode 0700
    end

    file "/home/#{username}/.ssh/authorized_keys" do
        owner username
        group username
        mode 0600
        content info[:key]
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