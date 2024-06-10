
# JMX Exporter HDFS Datanode

    export default header: 'Collectd Exporter Start', handler: ({options}) ->

## Start

      @service.start 'prometheus-collectd-exporter'
