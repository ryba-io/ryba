
# JMX Exporter HDFS Datanode

    export default header: 'JMX Exporter RegionServer Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-hbase-regionserver'
