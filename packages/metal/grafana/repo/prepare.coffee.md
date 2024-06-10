
# Grafana Repository Prepare

Download the grafana.repo file if available

    export default
      header: 'Grafana Repo Prepare'
      if: (options) -> options.prepare
      ssh: false
      handler: (options) ->
        @file.cache
          location: true
          source: options.source
