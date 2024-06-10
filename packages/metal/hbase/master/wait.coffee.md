
# HBase Master Wait

    export default  header: 'HBase Master Wait', handler: ({options}) ->

## RPC Port

      @connection.wait
        header: 'RPC'
        servers: options.rpc

## HTTP Port

      @connection.wait
        header: 'HTTP'
        servers: options.http
