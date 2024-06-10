
# HBase RegionServer Status

Check if the HBase RegionServer is running. The process ID is located by default
inside "/var/run/hbase/hbase-hbase-regionserver.pid".

    export default header: 'HBase RegionServer Status', handler: ({options}) ->
      @service.status
        name: 'hbase-regionserver'
        code_stopped: [1, 3]
