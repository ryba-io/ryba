
# Titan Prepare

Download the rpm package.

    module.exports =
      header: 'Titan Prepare'
      if: -> @contexts('ryba/titan')[0]?.config.host is @config.host
      handler: ->
        @file.cache
          ssh: null
          source: "#{@config.ryba.titan.source}"
