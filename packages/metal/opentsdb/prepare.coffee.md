
# OpenTSDB Prepare

Download the rpm package.

    export default
      header: 'OpenTSDB Prepare'
      ssh: false
      handler: (options) ->
        @file.cache
          source: "#{options.source}"
          location: true
