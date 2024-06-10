
# NiFi Status

    export default header: 'NiFi Status', handler: ->
      @service.status
        name: 'nifi'
        code_stopped: 1
