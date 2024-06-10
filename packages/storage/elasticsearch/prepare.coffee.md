
# Elasticsearch Prepared

    export default header: 'ES Prepared', handler: ->
      {elasticsearch, realm} = @config.ryba
      @file.cache
        ssh: false
        source: elasticsearch.source
        # target: "/var/tmp/elasticsearch-#{elasticsearch.version}.noarch.rpm"
