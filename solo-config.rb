chef_base = File.dirname(File.expand_path(__FILE__))

cookbook_path    chef_base
role_path        chef_base + '/roles/'
file_cache_path  chef_base
file_store_path  chef_base
log_level        :info
log_location     STDOUT
ssl_verify_mode  :verify_none
verbose_logging  false