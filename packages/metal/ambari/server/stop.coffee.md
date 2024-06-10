
# Ambari Server Stop

    export default header: 'Ambari Server Stop', handler: ->
        @service.stop
          name: 'ambari-server'
