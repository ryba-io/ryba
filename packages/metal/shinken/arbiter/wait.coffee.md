
# Shinken Arbiter Wait

    export default header: 'Shinken Arbiter Wait', handler: ->
      @connection.wait options.wait.tcp
