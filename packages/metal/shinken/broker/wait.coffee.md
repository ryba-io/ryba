
# Shinken Broker Wait

    export default header: 'Shinken Broker Wait', handler: (options) ->
      @connection.wait options.wait.tcp
