# installation
default['redis']['install_type'] = "package"
default['redis']['source']['sha'] = "03d849bc18a1f1849010064805e9f084857aaaab"
default['redis']['source']['url'] = "http://redis.googlecode.com/files"
default['redis']['source']['version'] = "2.6.0-rc7"
default['redis']['src_dir'] = "/usr/src/redis"
default['redis']['dst_dir'] = "/opt/redis"
default['redis']['conf_dir'] = "/etc/redis"
default['redis']['init_style'] = "init"

# service user & group
default['redis']['user'] = "redis"
default['redis']['group'] = "redis"

# configuration
default['redis']['config']['appendonly'] = "no"
default['redis']['config']['appendfsync'] = "everysec"
default['redis']['config']['daemonize'] = "yes"
default['redis']['config']['databases'] = "16"
default['redis']['config']['dbfilename'] = "dump.rdb"
default['redis']['config']['dir'] = "/var/lib/redis"
default['redis']['config']['listen_addr'] = "127.0.0.1"
default['redis']['config']['listen_port'] = "6379"
default['redis']['config']['logfile'] = "stdout"
default['redis']['config']['loglevel'] = "warning"
default['redis']['config']['pidfile'] = "/var/run/redis.pid"
default['redis']['config']['rdbcompression'] = "yes"
default['redis']['config']['timeout'] = "300"

###
## the following configuration settings may only work with a recent redis release
###
default['redis']['config']['configure_slowlog'] = false
default['redis']['config']['slowlog_log_slower_than'] = "10000"
default['redis']['config']['slowlog_max_len'] = "1024"

default['redis']['config']['configure_maxmemory_samples'] = false
default['redis']['config']['maxmemory_samples'] = "3"

default['redis']['config']['configure_no_appendfsync_on_rewrite'] = false
default['redis']['config']['no_appendfsync_on_rewrite'] = "no"

default['redis']['config']['configure_list_max_ziplist'] = false
default['redis']['config']['list_max_ziplist_entries'] = "512"
default['redis']['config']['list_max_ziplist_value'] = "64"

default['redis']['config']['configure_set_max_intset_entries'] = false
default['redis']['config']['set_max_intset_entries'] = "512"

default['redis']['config']['configure_hash_max_ziplist'] = false
default['redis']['config']['hash_max_ziplist_entries'] = "64"
default['redis']['config']['hash_max_ziplist_value'] = "512"

default['redis']['config']['vm']['enabled'] = "no"
default['redis']['config']['vm']['max_memory'] = "0"
default['redis']['config']['vm']['max_threads'] = "4"
default['redis']['config']['vm']['page_size'] = "32"
default['redis']['config']['vm']['pages'] = "134217728"
default['redis']['config']['vm']['vm_swap_file'] = "/var/lib/redis/redis.swap"