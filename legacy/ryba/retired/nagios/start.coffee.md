
# Nagios Start

    export default header: 'Nagios Start', handler: ->
      @service.start
        name: 'nagios'
        code_stopped: 1
