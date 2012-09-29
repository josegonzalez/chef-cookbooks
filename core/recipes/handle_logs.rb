logrotate '/etc/logrotate.d/mysqld-err' do
  path '/var/log/mysql/mysqld.err'
  role 'mysql'
end

logrotate '/etc/logrotate.d/mysql-slow' do
  path '/var/log/mysql/mysql-slow.log'
  role 'mysql'
end

logrotate '/etc/logrotate.d/redis-server' do
  path '/var/log/redis/redis-server.log'
  role 'redis'
end
