
export default 
  metadata:
    header: 'DB admin Wait'
  handler: (options) ->
    @connection.wait
      header: 'TCP'
      servers: options.tcp
