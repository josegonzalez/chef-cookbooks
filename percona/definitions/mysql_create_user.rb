define :mysql_create_user, :passwd => false, :grant => false, :grant_db => false, :root_password => false do
  [ "%" ].each do |ip|
    cmd = []

    cmd << "create user '%s'@'%s'" % [ params[:name], ip ]
    cmd << "identified by '%s'" % [ params[:passwd] ] if params[:passwd]
    cmd << ';'

    cmd << "grant %s on %s.* to '%s'@'%s'" % [ params[:grant], (params[:grant_db] || '*'), params[:name], ip ] if params[:grant]
    cmd << 'with grant option' if params[:grant] == 'all'
    cmd << ';'

    cmd << "flush privileges"

    execute "creating mysql user %s@%s" % [ params[:name], ip ] do
      command 'mysql -uroot  -p%s --execute="%s"' % [ params[:root_password], cmd.join(' ') ]
      not_if "mysql -uroot -p%s --silent --skip-column-names --database=mysql --execute=\"select User from user where User = '%s' and host = '%s'\" 2>&1 | grep ^%s" % [ params[:root_password], params[:name], ip, params[:name] ]
    end
  end
end