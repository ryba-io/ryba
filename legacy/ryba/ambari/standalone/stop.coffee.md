
# Ambari Server Stop

    export default header: 'Ambari Standalone Stop', handler: ->
        @service.stop
          name: 'ambari-server'
