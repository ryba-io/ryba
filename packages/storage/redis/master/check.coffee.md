
# Redis Master Check

The first check is done thourgh the redis-cli command line. Write 'ping' and redis
should respond 'pong'

    export default header: 'Redis Master Check', handler: (options) ->
      
## Wait

      @connection.assert
        header: 'Check tcp'
        wait: options.wait

      @system.execute
        cmd: """
          redis-cli -a #{options.conf.requirepass} -h #{options.fqdn} \
          -p #{options.conf.port} ping | grep PONG
          """
