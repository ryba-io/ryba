
export default
  header: 'MariaDB Client Install'
  handler: (options) ->
    @service
      if_os: name: ['redhat','centos'], version: '7'
      name: 'mariadb'
    @service
      if_os: name: ['redhat','centos'], version: '6'
      name: 'mysql'
    # Install the Mysql JDBC driver.
    @service
      header: 'Connector'
      name: 'mysql-connector-java'
