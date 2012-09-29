include_recipe "percona::keys"

package "percona-server-common-5.5" do
  action :install
end

package "percona-server-client-5.5" do
  action :install
end
