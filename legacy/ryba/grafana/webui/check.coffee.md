
# Grafana WEBUi Check
Check that the webui is listening for connections.

    export default header: 'Grafana WEBUi Check', handler: ({options}) ->
      
        @connection.assert
          retry: 5
          sleep: 5000
          header: 'Port'
          servers: options.wait.http.filter (server) -> server.host is options.fqdn
          retry: 20
          sleep: 5000
                
        
