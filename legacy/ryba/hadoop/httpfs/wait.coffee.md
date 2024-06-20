
# Hadoop HDFS NameNode Wait

    export default header: 'HDFS HttpFS Wait', handler: ({options}) ->

## HTTP Port

      @connection.wait
        header: 'HTTP'
        servers: options.http
