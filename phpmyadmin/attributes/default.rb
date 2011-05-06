include_attribute "apache2::default"

default[:pma][:version] = "3.3.9.2"
default[:pma][:checksum] = "b11988efe240dbb671c6ee90ac5c0ae97b0d228b4b24ce55b9f915a64c63ab49"
default[:pma][:subdomain] = "phpmyadmin"