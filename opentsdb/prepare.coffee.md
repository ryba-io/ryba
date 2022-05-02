
# OpenTSDB Prepare

Download the rpm package.

    module.exports =
      header: 'OpenTSDB Prepare'
      if: -> @contexts('ryba/opentsdb')[0]?.config.host is @config.host
      handler: ->
        @file.cache
          ssh: null
          source: "#{@config.ryba.opentsdb.source}"
          location: true
