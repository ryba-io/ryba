
# Shinken Arbiter Status

    export default header: 'Shinken Arbiter Status', handler: (options) ->
      @service.status name: 'shinken-arbiter'
