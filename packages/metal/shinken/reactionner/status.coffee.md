
# Shinken Reactionner Status

    export default  header: 'Shinken Reactionner Status', handler: (options) ->
      @service.status name: 'shinken-reactionner'
