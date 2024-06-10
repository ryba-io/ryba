
# JMX Exporter Zookeeper

    export default header: 'JMX Exporter Zookeeper Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-zookeeper-server'
