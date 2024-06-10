
# JMX Exporter Yarn ResourceManager

    export default header: 'JMX Exporter Yarn ResourceManager Stop', handler: ({options}) ->

## Start

      @service.stop 'jmx-exporter-yarn-resourcemanager'
