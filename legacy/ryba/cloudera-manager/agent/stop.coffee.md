
# Cloudera Manager Agent stop

    export default header: 'Cloudera Manager Agent Stop', handler: ->
      @service.stop
        name: 'cloudera-scm-agent'
