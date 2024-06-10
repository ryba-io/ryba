
# Druid Tranquility Prepare

Download the Tranquility package.

    export default header: 'Druid Tranquility Prepare', handler: ->
      {druid} = @config.ryba
      @file.cache
        ssh: false
        source: "#{druid.tranquility.source}"
