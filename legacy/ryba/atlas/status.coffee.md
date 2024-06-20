
# Atlas Metadata Server Status

Check if Atlas Server is started

    export default header: 'Atlas Status', handler: ->
      @service.status 'atlas-metadata-server'
