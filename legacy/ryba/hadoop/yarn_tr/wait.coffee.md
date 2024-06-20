
# Hadoop YARN Timeline Server Wait

Wait for the ResourceManager RPC and HTTP ports. It supports HTTPS and HA.

    export default header: 'YARN TR Wait', handler: ({options}) ->

## Webapp Address

      @connection.wait
        header: 'Webapp'
        servers: options.webapp
