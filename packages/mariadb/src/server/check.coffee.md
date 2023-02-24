
# MariaDB Server Check

    module.exports = $header: 'MariaDB Server Check', handler: ({config}) ->

## Runing Sevrice

Ensure the "ntpd" service is up and running.

      @service.assert
        $header: 'Service'
        name: config.name
        srv_name: config.srv_name
        installed: true
        started: true

## TCP Connection

Ensure the port is listening.

      @connection.wait
        retry: 3
        interval: 10000
      @connection.assert
        $header: 'TCP'
        host: config.wait_tcp.fqdn
        port: config.wait_tcp.port

## Check Replication

      @call
        $header: 'Replication'
        $if: config.ha_enabled
      , ->
        props =
          database: null
          admin_username: config.admin_username
          admin_password: config.admin_password
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

## Dependencies

    db = require '@nikitajs/core/lib/misc/db'
