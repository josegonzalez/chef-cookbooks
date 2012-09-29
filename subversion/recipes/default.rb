package "subversion" do
  action :install
end

case node[:platform]
when "ubuntu"
  package "subversion-tools" do
    action :install
  end
  if node[:platform_version].to_f < 8.04
    package "libsvn-core-perl" do
      action :install
    end
  else
    package "libsvn-perl" do
      action :install
    end
  end
when "centos","redhat","fedora"
  %w{subversion-devel subversion-perl}.each do |pkg|
    package pkg do
      action :install
    end
  end
else
  %w{subversion-tools libsvn-perl}.each do |pkg|
    package pkg do
      action :install
    end
  end
end