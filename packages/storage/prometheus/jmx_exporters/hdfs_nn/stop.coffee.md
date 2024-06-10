
# JMX Exporter HDFS Namenode

    export default header: 'JMX Exporter Namenode Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-hdfs-namenode'
