
# JMX Exporter HDFS Journalnode

    export default header: 'JMX Exporter Journalnode Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-hdfs-journalnode'
