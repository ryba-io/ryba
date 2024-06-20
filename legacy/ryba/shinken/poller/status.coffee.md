
# Shinken Poller Status

    export default  header: 'Shinken Poller Status', handler: (options) ->
      @service.status name: 'shinken-poller'
