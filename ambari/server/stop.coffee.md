
# Ambari Server Stop

    module.exports = header: 'Ambari Server Stop', label_true: 'STOPPED', handler: ->
        @service.stop
          name: 'ambari-server'
