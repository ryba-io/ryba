
# MapReduce JobHistoryServer Wait

    export default header: 'MapReduce JHS Wait', handler: ({options}) ->

## TCP

      @connection.wait
        header: 'TCP'
        servers: options.tcp

## HTTP

      @connection.wait
        header: 'HTTP'
        servers: options.webapp
