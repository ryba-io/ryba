
# JMX Exporter

JMX to Prometheus exporter.
A Collector that can configurably scrape and expose mBeans of a JMX target. 
It meant to be run as a Java Agent, exposing an HTTP server and scraping the local JVM.

    export default
      deps:
        ssl: module: 'masson/core/ssl', local: true
        java: module: 'masson/commons/java', local: true, required: true
        iptables: module: 'masson/core/iptables', local: true
        hdfs_dn: module: '@rybajs/metal/hadoop/hdfs_dn', local: true, required: true
        jmx_exporter: module: '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn'
        prometheus_monitor: module: '@rybajs/storage/prometheus/monitor', required: true
        hadoop_core: module: '@rybajs/metal/hadoop/core', local: true
      configure: '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/configure'
      plugin: ({options}) ->
        @before
          action: ['service']
          name: 'hadoop-hdfs-datanode'
        , ->
          delete options.original.action
          delete options.original.handler
          delete options.original.argument
          delete options.original.store
          @call '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/password.coffee.md', options.original
      commands:
        install: [
          '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/install'
          '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/start'
        ]
        start : [
          '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/start'
        ]
        stop : [
          '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/stop'
        ]
        prepare: [
          '@rybajs/storage/prometheus/jmx_exporters/hdfs_dn/prepare'
        ]
