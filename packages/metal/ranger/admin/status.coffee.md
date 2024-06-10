
# Ranger Admin Status

Check if Ranger Admin is started

    export default header: 'Ranger Admin Status', handler: ->
      @service.status 'ranger-admin'
