
# MySQL Server Wait

    module.exports = $header: 'MySQL Server Wait', handler: (config) ->
      throw Error "Required option: fqdn" unless config.fqdn
      throw Error "Required option: port" unless config.port

## Wait TCP

      @connection.wait
        $header: 'TCP'
        host: config.fqdn
        port: config.port
