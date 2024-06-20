
# Schema Registry Start

    export default header: 'Schema Registry Start', handler: ->
      @service.start name: 'registry'
