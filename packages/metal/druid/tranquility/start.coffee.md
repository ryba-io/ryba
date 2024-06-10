
# Tranquility Start

This commands starts Elastic Search using the default service command.

    export default header: 'Tranquility Start', handler: ->
      @service.start
        name: 'tranquility'
