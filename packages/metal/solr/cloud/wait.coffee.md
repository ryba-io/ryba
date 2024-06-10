
# Shinken Arbiter Wait

    export default header: 'Solr Cloud Wait', handler: (options) ->
      @connection.wait options.tcp
