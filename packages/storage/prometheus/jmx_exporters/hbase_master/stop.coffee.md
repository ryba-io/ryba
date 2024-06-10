
# JMX Exporter HDFS Datanode

    export default header: 'JMX Exporter HBase Master Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-hbase-master'
