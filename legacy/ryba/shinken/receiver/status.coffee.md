
# Shinken Receiver Status

    export default  header: 'Shinken Receiver Status', handler: (options) ->
      @service.status name: 'shinken-receiver'
