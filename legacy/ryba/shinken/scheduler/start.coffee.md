
# Shinken Scheduler Start

    export default header: 'Shinken Scheduler Start', handler: (options) ->
      @service.start name: 'shinken-scheduler'
