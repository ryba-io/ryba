
export default (service) ->
  options = service.options
  if service.deps.mariadb
    options.engine ?= 'mariadb'
  else if service.deps.postgresql
    options.engine ?= 'postgresql'
  else if service.deps.mysql
    options.engine ?= 'mysql'
  else
    options.engine ?= null
  # MariaDB
  # Auto discovered configuration
  if service.deps.mariadb
    options.mariadb ?= {}
    options.mariadb.discovered = true
    options.mariadb.engine = 'mariadb'
    options.mariadb.admin_username ?= 'root'
    options.mariadb.admin_password ?= service.deps.mariadb[0].options.admin_password
    options.mariadb.fqdns ?= service.deps.mariadb.map (srv) -> srv.node.fqdn
    options.mariadb.host ?= options.mariadb.fqdns[0]
    options.mariadb.port ?= service.deps.mariadb[0].options.my_cnf['mysqld']['port']
  # Manual configurattion
  else if options.mariadb
    throw Error "Required Options: fqdns" unless options.mariadb.fqdns
  # Default value of auto discovered and manual configurattion
  if options.mariadb
    options.mariadb.java ?= {}
    options.mariadb.java.driver = 'com.mysql.jdbc.Driver'
    options.mariadb.java.datasource = 'org.mariadb.jdbc.MariaDbDataSource'
    options.mariadb.port ?= 3306
    url = options.mariadb.fqdns.map((fqdn)-> "#{fqdn}:#{options.mariadb.port}").join(',')
    options.mariadb.jdbc ?= "jdbc:mysql://#{url}"
  if options.mariadb
    throw Error 'Required Option: mariadb.admin_username' unless options.mariadb.admin_username?
    throw Error 'Required Option: mariadb.admin_password' unless options.mariadb.admin_password?
  # PostgreSQL
  # Auto discovered configuration
  if service.deps.postgresql
    options.postgresql ?= {}
    options.postgresql.discovered = true
    options.postgresql.engine = 'postgresql'
    options.postgresql.admin_username ?= 'root'
    options.postgresql.admin_password ?= service.deps.postgresql[0].options.password
    options.postgresql.fqdns ?= service.deps.postgresql.map (srv) -> srv.node.fqdn
    options.postgresql.host ?= options.postgresql.fqdns[0]
    options.postgresql.port ?= service.deps.postgresql[0].options.port
    url = options.postgresql.fqdns.map((fqdn)-> "#{fqdn}:#{options.postgresql.port}").join(',')
    options.postgresql.jdbc ?= "jdbc:postgresql://#{url}"
  # Manual configurattion
  else if options.postgresql
    throw Error "Required Options: fqdns" unless options.postgresql.fqdns
  # Default value of auto discovered and manual configurattion
  if options.postgresql
    options.postgresql.java ?= {}
    options.postgresql.java.datasource = 'org.postgresql.jdbc2.Jdbc2PoolingDataSource'
    options.postgresql.java.driver = 'org.postgresql.Driver'
    options.postgresql.port ?= 5432
    url = options.postgresql.fqdns.map((fqdn)-> "#{fqdn}:#{options.postgresql.port}").join(',')
    options.postgresql.jdbc ?= "jdbc:postgresql://#{url}"
  if options.postgresql
    throw Error 'Required Option: postgresql.admin_username' unless options.postgresql.admin_username?
    throw Error 'Required Option: postgresql.admin_password' unless options.postgresql.admin_password?
  # Mysql
  # Auto discovered configuration
  if service.deps.mysql
    options.mysql ?= {}
    options.mysql.discovered = true
    options.mysql.engine = 'mysql'
    options.mysql.admin_username ?= 'root'
    options.mysql.admin_password ?= service.deps.mysql[0].options.admin_password
    options.mysql.fqdns ?= service.deps.mysql.map (srv) -> srv.node.fqdn
    options.mysql.host ?= options.mysql.fqdns[0]
    options.mysql.port ?= service.deps.mysql[0].options.my_cnf['mysqld']['port']
  # Manual configurattion
  else if options.postgresql
    throw Error "Required Options: fqdns" unless options.postgresql.fqdns
  # Default value of auto discovered and manual configurattion
  if options.mysql
    options.mysql.java ?= {}
    options.mysql.java.driver = 'com.mysql.jdbc.Driver'
    options.mysql.java.datasource = 'com.mysql.jdbc.jdbc2.optional.MysqlConnectionPoolDataSource'
    options.mysql.port ?= 3306
    url = options.mysql.fqdns.map((fqdn)-> "#{fqdn}:#{options.mysql.port}").join(',')
    options.mysql.jdbc ?= "jdbc:mysql://#{url}"
  if options.mysql
    throw Error 'Required Option: mysql.admin_username' unless options.mysql.admin_username?
    throw Error 'Required Option: mysql.admin_password' unless options.mysql.admin_password?
  # Wait
  options.wait_mariadb = service.deps.mariadb[0].options.wait if service.deps.mariadb
  options.wait_postgresql = service.deps.postgresql[0].options.wait if service.deps.postgresql
  options.wait_mysql = service.deps.mysql[0].options.wait if service.deps.mysql
  options.wait = {}
  options.wait.tcp = []
  if options.mariadb then for fqdn in options.mariadb.fqdns
    options.wait.tcp.push host: fqdn, port: options.mariadb.port
  if options.postgresql then for fqdn in options.postgresql.fqdns
    options.wait.tcp.push host: fqdn, port: options.postgresql.port
  if options.mysql then for fqdn in options.mysql.fqdns
    options.wait.tcp.push host: fqdn, port: options.mysql.port
