
# JMX Exporter HBase Master Check

    export default header: 'JMX Exporter HBase Master Check', handler: ({options}) ->

## Check Port

      @connection.assert
        header: 'TCP'
        servers: options.wait.jmx
        retry: 3
        sleep: 3000
