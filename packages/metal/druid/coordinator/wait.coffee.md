
# Druid Coordinator Wait

    export default header: 'Druid Coordinator Wait', handler: (options) ->

## TCP Port

      @connection.wait
        header: 'TCP'
        servers: options.tcp
