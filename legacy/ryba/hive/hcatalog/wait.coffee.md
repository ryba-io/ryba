
# Hive HCatalog Wait

Wait for the ResourceManager RPC and HTTP ports. It supports HTTPS and HA.


    export default header: 'Hive HCatalog Wait', handler: ({options}) ->

## RCP

The Hive metastore listener port, default to "9083".

      @connection.wait
        header: 'RPC'
        servers: options.rpc

## Dependencies

    url = require 'url'
