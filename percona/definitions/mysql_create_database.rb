define :mysql_create_database, :root_password => false  do
  execute "creating mysql database %s" % [ params[:name] ] do
    command 'mysql -uroot  -p%s --execute="CREATE DATABASE IF NOT EXISTS %s"' % [ params[:root_password], params[:name] ]
  end
end