ruby_block "Import databases" do
  block do

    require 'rubygems'
    Gem.clear_paths
    require 'mysql'

    databases = []

    # Get the databases to be imported
    Dir.foreach("/etc/uploads/sql") do |sql|
      next unless sql.end_with?('.sql')
      databases << sql[0..-5]
    end

    break if databases.empty?

    # Check if we should create any databases
    existing = []
    m = Mysql.new('localhost', "root", node[:mysql][:server_root_password])
    m.query('SHOW DATABASES').each { |database| existing << database.to_s}
    databases = databases - existing

    # import here
    databases.each do |database|
      puts '[' + DateTime.now.to_s + '] Creating ' + database
      m.query('CREATE DATABASE IF NOT EXISTS ' + database)

      puts '[' + DateTime.now.to_s + '] Importing data for ' + database
      Kernel.system("mysql -u root #{node['mysql']['server_root_password'].empty? ? '' : '-p' }#{node['mysql']['server_root_password']} -h localhost " + database + ' < /etc/uploads/sql/' + database + '.sql')
    end

  end
end

ruby_block "Create users" do
  block do

    require 'rubygems'
    Gem.clear_paths
    require 'mysql'

    # List all the existing users that we shouldn't touch
    existing = []
    m = Mysql.new('localhost', "root", node[:mysql][:server_root_password])
    m.query('SELECT User FROM mysql.user').each { |user| existing << user.to_s}

    node[:mysql][:users].each do |username, config|
      next if existing.include?(username)

      puts '[' + DateTime.now.to_s + '] Adding new user::' + username
      m.query(sprintf("CREATE USER '%s'@'localhost' IDENTIFIED BY  '%s'", username, config['password']))
      m.query(sprintf("GRANT USAGE ON `%s` . * TO  '%s'@'localhost' IDENTIFIED BY  '%s' 
                          WITH MAX_QUERIES_PER_HOUR 0 
                               MAX_CONNECTIONS_PER_HOUR 0 
                               MAX_UPDATES_PER_HOUR 0 
                               MAX_USER_CONNECTIONS 0 ", config['database'], username, config['password']))
      m.query(sprintf("GRANT ALL PRIVILEGES ON  `%s` . * TO  '%s'@'localhost'", config['database'], username))
    end

  end
end