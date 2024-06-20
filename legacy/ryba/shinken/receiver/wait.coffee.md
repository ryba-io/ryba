
# Shinken Receiver Wait

    export default header: 'Shinken Receiver Wait', handler: ->
      @connection.wait options.wait.tcp
