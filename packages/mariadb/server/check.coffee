import db from '@nikitajs/db/utils/db'

export default
  header: 'MariaDB Server Check'
  handler: ({options}) ->
    # Ensure the "ntpd" service is up and running.
    @service.assert
      header: 'Service'
      name: options.name
      srv_name: options.srv_name
      installed: true
      started: true
    # Ensure the port is listening.
    @connection.wait
      retry: 3
      interval: 10000
    @connection.assert
      header: 'TCP'
      host: options.wait_tcp.fqdn
      port: options.wait_tcp.port
    @call
      header: 'Replication'
      if: options.ha_enabled
    , ->
      props =
        database: null
        admin_username: options.admin_username
        admin_password: options.admin_password
        engine: 'mysql'
        host: 'localhost'
        silent: false
      @system.execute
        retry: 3
        cmd: "#{db.cmd props,'show slave status \\G ;'} | grep Slave_IO_State"
      , (err, data) ->
        throw err if err
        ok = /^Slave_IO_State:\sWaiting for master to send event/.test(data.stdout.trim() )or /^Slave_IO_State:\sConnecting to master/.test(data.stdout.trim())
        throw Error 'Error in Replication state' unless ok
