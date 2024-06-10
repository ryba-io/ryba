
# Spark History Server Status

    export default header: 'Spark History Server Status', handler: ->
      @service.status
        name: 'spark-history-server'
