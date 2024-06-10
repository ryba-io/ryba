
# HBase Thrift server Wait

    export default header: 'HBase Thrift Wait', handler: ({options}) ->

## HTTP Port

      @connection.wait
        header: 'HTTP'
        servers: options.http

## HTTP Info Port

      @connection.wait
        header: 'HTTP Info'
        servers: options.http_info
