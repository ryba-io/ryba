
# MongoDB Config Server Check

    export default header: 'MongoDB Config Server Check', handler: ({options}) ->

## Check

      @connection.assert
        header: 'TCP'
        servers: options.wait.tcp.filter (server) -> server.host is options.fqdn
        retry: 3
        sleep: 3000
