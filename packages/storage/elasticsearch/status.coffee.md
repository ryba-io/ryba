
# Elasticsearch Status

This commands checks the status of ElasticSearch (STARTED, STOPPED)

    export default header: 'ES Status', handler: ->
      @service.status name: 'elasticsearch'
