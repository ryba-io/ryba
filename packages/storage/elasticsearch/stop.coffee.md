
# Elasticsearch Stop

This commands stops Elasticsearch service.

    export default header: 'ES Stop', handler: ->
      @service.stop
        name: 'elasticsearch'
        if_exists: '/etc/init.d/elasticsearch'
