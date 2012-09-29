# Required packages
packages = [ "libevent-dev", "libxml2-dev", "libxslt1-dev", "snmp", "supervisor", "xfsprogs" ]

packages.each do |pkg|
  package pkg do
    action :install
  end
end

