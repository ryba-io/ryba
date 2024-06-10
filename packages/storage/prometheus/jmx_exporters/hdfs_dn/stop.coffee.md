
# JMX Exporter HDFS Datanode

    export default header: 'JMX Exporter Datanode Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-hdfs-datanode'
