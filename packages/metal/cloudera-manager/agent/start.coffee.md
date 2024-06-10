
# Cloudera Manager Agent Start

Cloudera Manager Agent is started with the service's syntax command.

    export default header: 'Cloudera Manager Agent Start', handler: ->
      @call once: true, '@rybajs/metal/cloudera-manager/server/wait'
      @service.start
        name: 'cloudera-scm-agent'
