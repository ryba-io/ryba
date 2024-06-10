
# DB Admin Wait

    export default  header: 'DB admin Wait', handler: (options) ->

## TCP Port

      @connection.wait
        header: 'TCP'
        servers: options.tcp
