
# HBase RegionServer Wait

    export default header: 'HBase RegionServer Wait', handler: ({options}) ->

## RPC Port

      @connection.wait
        header: 'RPC'
        servers: options.rpc

## Info Port

      @connection.wait
        header: 'Info'
        servers: options.info
