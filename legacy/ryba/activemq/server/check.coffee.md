
# ActiveMQ Server Check

    export default  header: 'ActiveMQ Server Check', handler: ->
      @connection.wait
        host: @config.host
        port: 8161
