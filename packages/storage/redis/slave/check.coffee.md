
# Redis Slave Check

The first check is done thourgh the redis-cli command line. Write 'ping' and redis
should respond 'pong'

    export default header: 'Redis Slave Check', handler: (options) ->
      
## Wait

      @call '@rybajs/storage/redis/master/wait'
      @call '@rybajs/storage/redis/slave/wait'

      @system.execute
        cmd: """
          redis-cli -a #{options.slave.conf.requirepass} -h #{@config.host} \
          -p #{options.slave.conf.port} ping | grep PONG
          """
