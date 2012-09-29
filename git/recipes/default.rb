case node['platform']
when "debian", "ubuntu"
  package "git-core"
when "centos", "redhat", "amazon", "scientific", "fedora"
  case node['platform_version'].to_i
  when 5
    include_recipe "yum::epel"
  end
  package "git"
else
  package "git"
end
