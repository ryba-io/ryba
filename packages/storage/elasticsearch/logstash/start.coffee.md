
# Logstash Start

This commands starts Logstash using the default service command.

    export default header: 'Logstash Start', handler: ->
      @service.start
        name: 'logstash'
