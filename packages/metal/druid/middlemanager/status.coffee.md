
# Druid MiddleManager Status

    export default header: 'Druid MiddleManager Status', handler: ->
      @service.status
        name: 'druid-middlemanager'
        if_exists: '/etc/init.d/druid-middlemanager'
