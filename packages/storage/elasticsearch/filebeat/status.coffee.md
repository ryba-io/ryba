
# Filebeat Status

This commands checks the status of Filebeat (STARTED, STOPPED)

    export default header: 'Filebeat Status', handler: ->
      @service.status name: 'filebeat'
