# Hortonworks Smartsense Server Check

Check for the HST server. Check the three ports (two way ssl ports and webui port)

    export default header: 'HST Server Wait', handler: (options) ->
      @connection.assert
        header: 'TCP'
        servers: options.wait_local
        retry: 3
        sleep: 3000
      @connection.assert
        header: 'TCP'
        servers: options.wait_local_ssl_one_way
        retry: 3
        sleep: 3000
      @connection.assert
        header: 'TCP'
        servers: options.wait_local_ssl_two_way
        retry: 3
        sleep: 3000
