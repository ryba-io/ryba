
# Druid Historical Status

    export default header: 'Druid Historical Status', handler: ->
      @service.status
        name: 'druid-historical'
        if_exists: '/etc/init.d/druid-historical'
