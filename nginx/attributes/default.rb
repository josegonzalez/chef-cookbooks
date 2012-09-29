default['nginx']['dir']     = "/etc/nginx"
default['nginx']['log_dir'] = "/var/log/nginx"
default['nginx']['user']    = "www-data"
default['nginx']['binary']  = "/usr/sbin/nginx"

default['nginx']['gzip'] = "on"
default['nginx']['gzip_http_version'] = "1.0"
default['nginx']['gzip_comp_level'] = "2"
default['nginx']['gzip_min_length'] = "1024"
default['nginx']['gzip_proxied'] = "any"
default['nginx']['gzip_static'] = "off"
default['nginx']['gzip_types'] = [
  "text/plain",
  "text/css",
  "application/x-javascript",
  "application/json",
  "text/xml",
  "application/xml",
  "application/xml+rss",
  "text/javascript",
  "image/png",
  "image/gif",
  "image/jpeg"
]
default['nginx']['gzip_vary'] = "on"
default['nginx']['keepalive']          = "on"
default['nginx']['keepalive_timeout']  = 65
default['nginx']['worker_processes']   = cpu[:total]
default['nginx']['worker_connections'] = 2048
default['nginx']['server_names_hash_bucket_size'] = 64
default['nginx']['client_max_body_size'] = "20M"
