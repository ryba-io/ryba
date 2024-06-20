
# Druid MiddleManager Wait

    export default header: 'Druid MiddleManager Wait', handler: (options) ->

## TCP Port

      @connection.wait
        header: 'TCP'
        servers: options.tcp
