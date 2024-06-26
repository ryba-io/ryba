
# HBase RegionServer Start

Start the RegionServer server. You can also start the server manually with one of the
following two commands:

```
service hbase-regionserver start
su -l hbase -c "/usr/hdp/current/hbase-regionserver/bin/hbase-daemon.sh --config /etc/hbase-regionserver/conf start regionserver"
```

    export default header: 'HBase RegionServer Start', handler: ({options}) ->

Wait for Kerberos, ZooKeeper, HDFS and HBase Master to be started.

      @call 'masson/core/krb5_client/wait', once: true,  options.wait_krb5_client
      @call '@rybajs/metal/zookeeper/server/wait', once: true,  options.wait_zookeeper_server
      @call '@rybajs/metal/hadoop/hdfs_dn/wait', once: true
      # @call '@rybajs/metal/hadoop/hdfs_nn/wait', once: true,  options.wait_hdfs_nn, conf_dir: options.hdfs_conf_dir
      @call '@rybajs/metal/hbase/master/wait', once: true, options.wait_hbase_master

Start the service.

      @service.start
        header: 'Service'
        name: 'hbase-regionserver'
