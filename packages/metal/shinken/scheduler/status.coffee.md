
# Shinken Scheduler Status

    export default  header: 'Shinken Scheduler Status', handler: (options) ->
      @service.status name: 'shinken-scheduler'
