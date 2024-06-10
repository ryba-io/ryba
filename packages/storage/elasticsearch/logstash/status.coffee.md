
# Logstash Status

This commands checks the status of Logstash (STARTED, STOPPED)

    export default header: 'Logstash Status', handler: ->
      @service.status name: 'logstash'
