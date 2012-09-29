define :mysql_create_table, :database => false, :root_password => false do
  cmd = []

  cmd << "CREATE TABLE IF NOT EXISTS %s.%s (" % [ params[:database], params[:name] ]
  cmd << "id int(11) NOT NULL"
  cmd << ") ENGINE=MyISAM DEFAULT CHARSET=latin1;"

  execute "creating database table %s::%s" % [ params[:name], params[:database] ] do
    command 'mysql -uroot  -p%s --execute="%s"' % [ params[:root_password], cmd.join(' ')]
  end
end
