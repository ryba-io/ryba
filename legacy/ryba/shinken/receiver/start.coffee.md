
# Shinken Receiver Start

    export default header: 'Shinken Receiver Start', handler: (options) ->
      @service.start name: 'shinken-receiver'
