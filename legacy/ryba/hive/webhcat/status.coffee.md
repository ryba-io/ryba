
# WebHCat Status

Check if the RegionServer is running. The process ID is located by default
inside "/var/run/webhcat/webhcat.pid".

    export default header: 'WebHCat Status', handler: ->
      @service.status
        name: 'hive-webhcat-server'
