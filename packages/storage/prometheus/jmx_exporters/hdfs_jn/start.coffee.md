
# JMX Exporter HDFS Journalnode

    export default header: 'JMX Exporter Journalnode Start', handler: ({options}) ->

## Start

      @service.start 'jmx-exporter-hdfs-journalnode'
