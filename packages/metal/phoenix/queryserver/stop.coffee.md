
# Phoenix QueryServer Stop

    export default header: 'Phoenix QueryServer Stop', handler: ->
      @service.stop name: 'phoenix-queryserver'
