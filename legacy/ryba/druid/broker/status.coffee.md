
# Druid Broker Status

    export default header: 'Druid Broker Status', handler: ->
      @service.status
        name: 'druid-broker'
        if_exists: '/etc/init.d/druid-broker'
