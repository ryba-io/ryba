
# Hive Server2 Wait

Wait for the RPC or HTTP ports depending on the configured transport mode.

    module.exports = header: 'Hive Server2 Wait', label_true: 'READY', handler: ->
      options = {}
      options.wait_thrift = for hive_ in @contexts 'ryba/hive/server2'
        host: hive_.config.host
        port: if hive_.config.ryba.hive.server2.site['hive.server2.transport.mode'] is 'http'
        then hive_.config.ryba.hive.server2.site['hive.server2.thrift.http.port']
        else hive_.config.ryba.hive.server2.site['hive.server2.thrift.port']

## Thrift TCP/HTTP Port

      @connection.wait
        header: 'Thrift'
        servers: options.wait_thrift
