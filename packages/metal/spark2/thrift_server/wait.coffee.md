
# Spark SQL Thrift Server Wait

Wait for the ResourceManager Thrift port (HTTP and BINARY).

    export default header: 'Spark SQL Thrift Server Wait', handler: ({options}) ->

## Wait Thrift TCP/HTTP Port

      @connection.wait
        header: 'Thrift'
        servers: options.wait.thrift
