
# Shinken Broker Status

    export default  header: 'Shinken Broker Status', handler: (options) ->
      @service.status name: 'shinken-broker'
