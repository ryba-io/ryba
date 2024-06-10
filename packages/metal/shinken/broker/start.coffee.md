
# Shinken Broker Start

    export default header: 'Shinken Broker Start', handler: (options) ->
      @service.start name: 'shinken-broker'
