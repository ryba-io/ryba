
# MongoDB Repository Prepare

Download the mongodb.repo file if available

    export default
      header: 'MongoDB Repo Prepare'
      ssh: false
      handler: ({options}) ->
        @file.cache
          if: options.download
          location: true
          source: options.source
