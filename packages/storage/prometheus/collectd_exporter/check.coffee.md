
# Collectd Exporter Check

    export default header: 'Collectd Exporter Check', handler: ({options}) ->

## Check Port

      @connection.assert
        header: 'TCP'
        servers: options.wait.jmx
        retry: 3
        sleep: 3000
