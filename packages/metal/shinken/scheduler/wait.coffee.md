
# Shinken Scheduler Wait

    export default header: 'Shinken Scheduler Wait', handler: (options) ->
      @connection.wait options.wait.http
