# Hortonworks Smartsense Server Wait

Wait for the HST server wait. Check the three ports (two way ssl ports and webui port)

    export default header: 'HST Server Wait', handler: (options) ->
      @connection.wait options.wait_local
      @connection.wait options.wait_local_ssl_one_way
      @connection.wait options.wait_local_ssl_two_way
