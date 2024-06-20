
# Shinken Reactionner Wait

    export default header: 'Shinken Reactionner Wait', handler: (options) ->
      @connection.wait options.wait.tcp
