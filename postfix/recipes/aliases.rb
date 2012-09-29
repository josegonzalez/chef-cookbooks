include_recipe "postfix::install"

execute "update-postfix-aliases" do
  command "newaliases"
  action :nothing
end

template "/etc/aliases" do
  source "etc/aliases.erb"
  notifies :run, resources("execute[update-postfix-aliases]")
  notifies :reload, resources(:service => "postfix")
end
