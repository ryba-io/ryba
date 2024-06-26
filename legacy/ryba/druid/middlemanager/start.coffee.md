
# Druid MiddleManager Start

    export default header: 'Druid MiddleManager Start', handler: (options) ->

## Wait

      @call 'masson/core/krb5_client/wait', once: true, options.wait_krb5_client
      @call '@rybajs/metal/zookeeper/server/wait', once: true, options.wait_zookeeper_server
      @call '@rybajs/metal/hadoop/hdfs_nn/wait', once: true, options.wait_hdfs_nn
      @call '@rybajs/metal/druid/coordinator/wait', once: true, options.wait_druid_coordinator
      @call '@rybajs/metal/druid/overlord/wait', once: true, options.wait_druid_overlord

## Kerberos Ticket

      @krb5.ticket
        header: 'Kerberos Ticket'
        uid: options.user.name
        principal: options.krb5_service.principal
        keytab: options.krb5_service.keytab

## Service

      @service.start
        header: 'Service'
        name: 'druid-middlemanager'
      
## Assert TCP

      @connection.assert
        header: 'TCP'
        servers: options.wait.tcp.filter (server) -> server.host is options.fqdn
        retry: 3
        sleep: 3000
