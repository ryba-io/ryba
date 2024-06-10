
# NiFi Stop

    export default header: 'NiFi Stop', handler: ->
      @service.stop name: 'nifi'
