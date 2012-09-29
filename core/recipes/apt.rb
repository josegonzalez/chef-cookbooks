template "/etc/apt/sources.list" do
  source "etc/apt/sources.list.erb"
  mode 00644
end
