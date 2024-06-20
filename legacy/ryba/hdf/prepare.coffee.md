
# HDF Repository Prepare

Download the hdf.repo file if available

    export default 
      header: 'HDF Repo Prepare'
      if: @contexts('@rybajs/metal/hdf')[0].config.host is @config.host
      ssh: false
      handler: (options) ->
        @file.cache
          location: true
          source: options.source
