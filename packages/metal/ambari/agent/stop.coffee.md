
# Ambari Agent stop

    export default  header: 'Ambari Agent Stop', handler: ->
        @service.stop
          name: 'ambari-agent'
