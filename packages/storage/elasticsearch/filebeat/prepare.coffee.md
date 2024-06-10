
# Filebeat Prepare

    export default header: 'Filebeat Prepare', handler: (options) ->
      @file.cache
        ssh: null
        source: "#{options.source}"
