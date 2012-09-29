define :mysql_set_password, :passwd => false, :grant => false, :grant_db => false, :root_password => false do
  params[:ips].each do |ip|
    cmd = []
    run_command = []
    not_if_command = []

    # HACK: Create the root user if it does not exist
    cmd << 'grant all privileges on *.*' if params[:name] == 'root'
    cmd << "to '%s'@'%s' identified by '%s'" % [ params[:name], ip, params[:passwd]] if params[:name] == 'root'
    cmd << 'with grant option;' if params[:name] == 'root'

    cmd << "set password for '%s'@'%s'" % [ params[:name], ip ]
    cmd << "= password('%s')" % [ params[:passwd] ] if params[:passwd]
    cmd << ';'
    cmd << "grant %s on %s.* to '%s'@'%s'" % [ params[:grant], (params[:grant_db] || '*'), params[:name], ip ] if params[:grant]
    cmd << 'with grant option' if params[:grant] == 'all'
    cmd << ';'
    cmd << "flush privileges"

    run_command << "with_status=1"
    run_command << 'mysql --silent -uroot -p%s --database=mysql --execute="select 1" 2>&1|grep ^ERROR'
    run_command << "if [[ $? -ne 0 ]]"
    run_command << 'then mysql -uroot -p%s --execute="%s"; with_status=$?'
    run_command << 'else mysql -uroot --execute="%s"; with_status=$?'
    run_command << "fi"
    run_command << "exit $with_status"

    not_if_command << "with_status=1"
    not_if_command << 'mysql --silent -uroot -p%s --database=mysql --execute="select 1" 2>&1|grep ^ERROR'
    not_if_command << "if [[ $? -ne 0 ]]"
    not_if_command << 'then mysql -uroot -p%s --silent --skip-column-names --database=mysql --execute="%s" 2>&1 | grep ^%s; with_status=$?'
    not_if_command << 'else mysql -uroot --silent --skip-column-names --database=mysql --execute="%s" 2>&1 | grep ^%s; with_status=$?'
    not_if_command << "fi"
    not_if_command << "exit $with_status"

    check = 'select User from user where Password = password(\'%s\') and host = \'%s\'' % [ params[:passwd], ip ]

    execute "updating user %s@%s" % [ params[:name], ip ] do
      command run_command.join(';') % [ params[:root_password], params[:root_password], cmd.join(' '),  cmd.join(' ') ]
      not_if not_if_command.join(';') % [ params[:root_password], params[:root_password], check, params[:name], check, params[:name] ]
    end
  end
end