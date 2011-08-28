set[:nginx][:dir]     = "/etc/nginx"
set[:nginx][:log_dir] = "/var/log/nginx"
set[:nginx][:user]    = "www-data"
set[:nginx][:binary]  = "/usr/sbin/nginx"

set_unless[:nginx][:gzip] = "on"
set_unless[:nginx][:gzip_http_version] = "1.0"
set_unless[:nginx][:gzip_comp_level] = "2"
set_unless[:nginx][:gzip_min_length] = "1024"
set_unless[:nginx][:gzip_proxied] = "any"
set_unless[:nginx][:gzip_static] = "off"
set_unless[:nginx][:gzip_types] = [
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
set_unless[:nginx][:gzip_vary] = "on"

set_unless[:nginx][:keepalive]          = "on"
set_unless[:nginx][:keepalive_timeout]  = 65
set_unless[:nginx][:worker_processes]   = 16
set_unless[:nginx][:worker_connections] = 2048
set_unless[:nginx][:server_names_hash_bucket_size] = 64
set_unless[:nginx][:client_max_body_size] = "20M"
