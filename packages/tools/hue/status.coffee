
export default header: 'Hue Status', handler: ->
  @service.status
    name: 'hue'
