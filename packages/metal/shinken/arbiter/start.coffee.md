
# Shinken Arbiter Start

    export default header: 'Shinken Arbiter Start', handler: (options) ->
      @service.start name: 'shinken-arbiter'
