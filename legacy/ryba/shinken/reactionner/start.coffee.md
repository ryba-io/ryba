
# Shinken Reactionner Start

    export default header: 'Shinken Reactionner Start', handler: (options) ->
      @service.start name: 'shinken-reactionner'
