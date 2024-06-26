
# JMX Exporter

JMX to Prometheus exporter.
A Collector that can configurably scrape and expose mBeans of a JMX target. 
It meant to be run as a Java Agent, exposing an HTTP server and scraping the local JVM.

    export default
      deps:
        java: module: 'masson/commons/java', local: true, required: true
        iptables: module: 'masson/core/iptables', local: true
        zookeeper_server: module: '@rybajs/metal/zookeeper/server', local: true, required: true
        jmx_exporter: module: '@rybajs/storage/prometheus/jmx_exporters/zookeeper'
        hadoop_core: module: '@rybajs/metal/hadoop/core', local: true
        prometheus_monitor: module: '@rybajs/storage/prometheus/monitor', required: true
      configure: '@rybajs/storage/prometheus/jmx_exporters/zookeeper/configure'
      commands:
        install: [
          '@rybajs/storage/prometheus/jmx_exporters/zookeeper/install'
          '@rybajs/storage/prometheus/jmx_exporters/zookeeper/start'
        ]
        start : [
          '@rybajs/storage/prometheus/jmx_exporters/zookeeper/start'
        ]
        stop : [
          '@rybajs/storage/prometheus/jmx_exporters/zookeeper/stop'
        ]
        prepare: [
          '@rybajs/storage/prometheus/jmx_exporters/zookeeper/prepare'
        ]
