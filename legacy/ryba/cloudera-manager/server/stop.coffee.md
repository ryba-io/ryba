
# Cloudera Manager Server stop

    export default header: 'Cloudera Manager Server Stop', handler: ->
      @service.stop
        name: 'cloudera-scm-server'
