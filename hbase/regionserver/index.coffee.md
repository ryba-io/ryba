
# HBase RegionServer

[HRegionServer](http://hbase.apache.org/book.html#regionserver.arch) is the
RegionServer implementation.
It is responsible for serving and managing regions. 
In a distributed cluster, a RegionServer runs on a DataNode.

    module.exports =
      use:
        iptables: implicit: true, module: 'masson/core/iptables'
        krb5_client: module: 'masson/core/krb5_client'
        hadoop_core: implicit: true, module: 'ryba/hadoop/core'
        java: implicit: true, module: 'masson/commons/java'
        hdfs_client: 'ryba/hadoop/hdfs_client'
        hbase_master: 'ryba/hbase/master'
        ranger_admin: 'ryba/ranger/admin'
        ganglia: 'ryba/ganglia/collector'
      configure: [
        'ryba/hbase/lib/configure_metrics'
        'ryba/hbase/regionserver/configure'
        'ryba/ranger/plugins/hbase/configure'
      ]
      commands:
        'check':
          'ryba/hbase/regionserver/check'
        'install': [
          'ryba/hbase/regionserver/install'
          'ryba/hbase/regionserver/start'
          'ryba/hbase/regionserver/check'
        ]
        'start':
          'ryba/hbase/regionserver/start'
        'status':
          'ryba/hbase/regionserver/status'
        'stop':
          'ryba/hbase/regionserver/stop'
