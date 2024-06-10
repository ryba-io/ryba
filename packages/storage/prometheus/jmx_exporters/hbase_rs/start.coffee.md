
# JMX Exporter HDFS Datanode

    export default header: 'JMX Exporter RegionServer Start', handler: ({options}) ->

## Start

      @service.start 'jmx-exporter-hbase-regionserver'
