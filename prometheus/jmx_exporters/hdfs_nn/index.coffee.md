
# JMX Exporter

JMX to Prometheus exporter.
A Collector that can configurably scrape and expose mBeans of a JMX target. 
It meant to be run as a Java Agent, exposing an HTTP server and scraping the local JVM.

    module.exports =
      deps:
        java: module: 'masson/commons/java', local: true, required: true
        iptables: module: 'masson/core/iptables', local: true
        hdfs_nn: module: 'ryba/hadoop/hdfs_nn', local: true, required: true
        jmx_exporter: module: 'ryba/prometheus/jmx_exporters/hdfs_nn'
        prometheus_monitor: module: 'ryba/prometheus/monitor', required: true
        hadoop_core: module: 'ryba/hadoop/core', local: true
      configure: 'ryba/prometheus/jmx_exporters/hdfs_nn/configure'
      commands:
        install: [
          'ryba/prometheus/jmx_exporters/hdfs_nn/install'
          'ryba/prometheus/jmx_exporters/hdfs_nn/start'
        ]
        start : [
          'ryba/prometheus/jmx_exporters/hdfs_nn/start'
        ]
        stop : [
          'ryba/prometheus/jmx_exporters/hdfs_nn/stop'
        ]
        prepare: [
          'ryba/prometheus/jmx_exporters/hdfs_nn/prepare'
        ]