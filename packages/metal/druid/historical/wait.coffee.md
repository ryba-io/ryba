
# Druid Historical Wait

    export default header: 'Druid Historical Wait', handler: (options) ->

## TCP Port

      @connection.wait
        header: 'TCP'
        servers: options.tcp
