
# Titan Prepare

Download the rpm package.

    export default
      header: 'Titan Prepare'
      if: -> @contexts('@rybajs/metal/titan')[0]?.config.host is @config.host
      ssh: false
      handler: ->
        @file.cache
          source: "#{@config.ryba.titan.source}"
