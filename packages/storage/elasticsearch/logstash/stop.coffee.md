
# Logstash stop

This commands stops Logstash using the default service command.

    export default header: 'Logstash Start', handler: ->
      @service.stop
        name: 'logstash'
