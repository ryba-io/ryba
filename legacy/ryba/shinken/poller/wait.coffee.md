
# Shinken Poller Wait

    export default header: 'Shinken Poller Wait', handler: (options) ->
      @connection.wait options.wait.tcp
