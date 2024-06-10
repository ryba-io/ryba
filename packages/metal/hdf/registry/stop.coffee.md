
# Schema Registry Stop

    export default header: 'Schema Registry Stop', handler: ->
      @service.stop name: 'registry'
