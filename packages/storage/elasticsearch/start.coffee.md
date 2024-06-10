
# Elasticsearch Start

This commands starts Elastic Search using the default service command.

    export default header: 'ES Start', handler: ->
      @service.start
        name: 'elasticsearch'
