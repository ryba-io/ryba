
# OpenTSDB Wait

Wait for the HTTP port.

    export default header: 'OpenTSDB Wait', handler: (options) ->
      options = {}
      options.servers =
        host: options.fqdn
        port:options.config['tsd.network.port']

## HTTP Port

      @connection.wait
        header: 'HTTP'
      , options
