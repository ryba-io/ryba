
# Druid Overlord Status

    export default header: 'Druid Overlord Status', handler: ->
      @service.status
        name: 'druid-overlord'
        if_exists: '/etc/init.d/druid-overlord'
