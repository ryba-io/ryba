
# Phoenix QueryServer Status

    export default header: 'Phoenix QueryServer Status', handler: ->
      @service.status
        name: 'phoenix-queryserver'
