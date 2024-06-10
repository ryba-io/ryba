
export default
  header: 'Ambari Agent Start'
  handler: ->
    @service.start
      name: 'ambari-agent'
