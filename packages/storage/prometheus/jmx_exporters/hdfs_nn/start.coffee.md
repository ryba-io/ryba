
# JMX Exporter HDFS Namenode

    export default header: 'JMX Exporter Namenode Start', handler: ({options}) ->

## Start

      @service.start 'jmx-exporter-hdfs-namenode'
