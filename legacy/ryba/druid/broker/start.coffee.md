
# Druid Broker Start

    export default header: 'Druid Broker Start', handler: (options) ->

## Wait

      @call '@rybajs/metal/zookeeper/server/wait', once: true, options.wait_zookeeper_server
      @call '@rybajs/metal/druid/coordinator/wait', once: true, options.wait_druid_coordinator
      @call '@rybajs/metal/druid/overlord/wait', once: true, options.wait_druid_overlord
      @call '@rybajs/metal/druid/historical/wait', once: true, options.wait_druid_historical
      @call '@rybajs/metal/druid/middlemanager/wait', once: true, options.wait_druid_middlemanager

## Kerberos Ticket

      @krb5.ticket
        header: 'Kerberos Ticket'
        uid: "#{options.user.name}"
        principal: "#{options.krb5_service.principal}"
        keytab: "#{options.krb5_service.keytab}"

## Service

      @service.start
        header: 'Service'
        name: 'druid-broker'
      
## Assert TCP

      @connection.assert
        header: 'TCP'
        servers: options.wait.tcp.filter (server) -> server.host is options.fqdn
        retry: 5
        sleep: 5000
