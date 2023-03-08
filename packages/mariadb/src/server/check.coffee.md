
# MariaDB Server Check

    module.exports = $header: 'MariaDB Server Check', handler: ({config}) ->

## Runing Service

Ensure the "ntpd" service is up and running.

      await @service.assert
        $header: 'Service'
        name: config.name
        srv_name: config.srv_name
        installed: true
        started: true

## TCP Connection

Ensure the port is listening.

      await @network.tcp.wait
        $retry: 3
        interval: 10000
        host: config.wait_tcp.fqdn
        port: config.wait_tcp.port
      
      await @network.tcp.assert
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
        await @execute
          $retry: 3
          command: "#{db.command props,'show slave status \\G ;'} | grep Slave_IO_State"
        , (err, data) ->
          throw err if err
          ok = /^Slave_IO_State:\sWaiting for master to send event/.test(data.stdout.trim() )or /^Slave_IO_State:\sConnecting to master/.test(data.stdout.trim())
          throw Error 'Error in Replication state' unless ok

## Dependencies

    {db} = require '@nikitajs/db/lib/utils'
