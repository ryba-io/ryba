
# JanusGraph Prepare

Download the package.

    export default
      header: 'JanusGraph Prepare'
      if: -> @contexts('@rybajs/metal/janusgraph')[0]?.config.host is @config.host
      ssh: false
      handler: (options) ->
        @file.cache
          source: "#{options.source}"
