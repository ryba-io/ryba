
## Hbase Thrift server check

    export default header: 'HBase Thrift Check', handler: ({options}) ->

## Assert HTTP Port

      @connection.assert
        header: 'HTTP'
        servers: options.wait.http.filter (server) -> server.host is options.fqdn
        retry: 10
        sleep: 3000

## Assert HTTP Info Port

      @connection.assert
        header: 'HTTP Info'
        servers: options.wait.http_info.filter (server) -> server.host is options.fqdn
        retry: 10
        sleep: 3000

# TODO: Novembre 2015 check Thrift  server by interacting with hbase

For now Hbase provided example does not work with SSL enabled Hbase Thrift Server.
