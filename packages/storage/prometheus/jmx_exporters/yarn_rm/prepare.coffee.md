
# JMX Exporter Yarn ResourceManager Prepare

    export default
      header: 'JMX Exporter Prepare'
      ssh: false
      handler: ({options}) ->
        @file.cache
          if: options.download
          header: "Standalone Jar #{options.version}"
          location: true
          # md5: info.md5
          # sha256: info.jdk_sha256
        , "#{options.standalone_source}"
        @file.cache
          if: options.download
          header: "Agent Jar #{options.version}"
          location: true
          # md5: info.md5
          # sha256: info.jdk_sha256
        , "#{options.agent_source}"
