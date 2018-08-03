
# JMX Exporter

JMX to Prometheus exporter.
A Collector that can configurably scrape and expose mBeans of a JMX target. 
It meant to be run as a Java Agent, exposing an HTTP server and scraping the local JVM.

    module.exports =
      deps:
        ssl: module: 'masson/core/ssl', local: true
        java: module: 'masson/commons/java', local: true, required: true
        iptables: module: 'masson/core/iptables', local: true
        hbase_rest: module: 'ryba/hbase/rest', local: true, required: true
        jmx_exporter: module: 'ryba/prometheus/jmx_exporters/hbase_rest'
        prometheus_monitor: module: 'ryba/prometheus/monitor', required: true
        hadoop_core: module: 'ryba/hadoop/core', local: true
      configure: 'ryba/prometheus/jmx_exporters/hbase_rest/configure'
      plugin: (options) ->
        @before
          action: ['service']
          name: 'hbase-rest'
        , ->
          delete options.original.action
          delete options.original.handler
          delete options.original.argument
          delete options.original.store
          @call 'ryba/prometheus/jmx_exporters/hbase_rest/password.coffee.md', options.original
      commands:
        install: [
          'ryba/prometheus/jmx_exporters/hbase_rest/install'
          'ryba/prometheus/jmx_exporters/hbase_rest/start'
        ]
        start : [
          'ryba/prometheus/jmx_exporters/hbase_rest/start'
        ]
        stop : [
          'ryba/prometheus/jmx_exporters/hbase_rest/stop'
        ]
        prepare: [
          'ryba/prometheus/jmx_exporters/hbase_rest/prepare'
        ]
        password: [
          'ryba/prometheus/jmx_exporters/hbase_rest/password.coffee.md'
        ]