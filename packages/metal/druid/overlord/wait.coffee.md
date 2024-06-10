
# Druid Overlord Wait

    export default header: 'Druid Overlord Wait', handler: (options) ->

## TCP Port

      @connection.wait
        header: 'TCP'
        servers: options.tcp
