
# Filebeat Start

This commands starts Filebeat using the default service command.

    export default header: 'Filebeat Start', handler: ->
      @service.start
        name: 'filebeat'
