
# Shinken Arbiter Status

    module.exports = header: 'Shinken Arbiter Status', handler: (options) ->
      @service.status name: 'shinken-arbiter'
