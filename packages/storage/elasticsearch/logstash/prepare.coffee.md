
# Logstash Prepare

    export default header: 'Logstash Prepare', handler: (options) ->
      @file.cache
        ssh: null
        source: "#{options.source}"
