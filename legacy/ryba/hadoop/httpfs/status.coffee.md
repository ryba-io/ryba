
# HDFS HttpFS Status

Check if HTTPFS is running. The process ID is located by default
inside "/var/run/httpfs/httpfs.pid".

    export default header: 'HDFS HttpFS Status', handler: ->
      @service.status
        name: 'hadoop-httpfs'
