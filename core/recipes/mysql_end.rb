# Create initial user
# TODO: Use pre-seeding here instead
# mysql_set_password 'root' do
#   ips             [ '%', '127.0.0.1', 'localhost' ]
#   passwd          node['mysql']['users']['root']['password']
#   root_password   node['mysql']['users']['root']['password']
#   grant           'all'
# end

# Create MySQL users
node['mysql']['users'].each do |username, u|
  mysql_create_user u['username'] do
    root_password   node['mysql']['users']['root']['password']
    passwd          u['password']
    grant           u['grant']
  end
end

# Special case for debian/ubntu maintenance user
debian_user    = node['mysql']['debian-sys-maint']['username']
debian_user_pw = node['mysql']['debian-sys-maint']['password']

mysql_ensure_user debian_user do
  ips             [ '%', '127.0.0.1', 'localhost' ]
  root_password   node['mysql']['users']['root']['password']
  passwd          debian_user_pw
  grant           'all'
end

template "/etc/mysql/debian.cnf" do
  source "etc/mysql/debian.cnf.erb"
  variables(
    :debian_user => debian_user,
    :debian_user_pw => debian_user_pw
  )
  owner "root"
  group "root"
  mode  0644
end
