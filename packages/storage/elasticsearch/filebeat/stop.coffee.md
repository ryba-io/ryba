
# Filebeat Stop

This commands stops Filebeat using the default service command.

    export default header: 'Filebeat Stop', handler: ->
      @service.stop
        name: 'filebeat'
