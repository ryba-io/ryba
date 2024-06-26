
# Oozie Server Start

Run the command `./bin/ryba start -m @rybajs/metal/oozie/server` to start the Oozie
server using Ryba.

By default, the pid of the running server is stored in
"/var/run/oozie/oozie.pid".

Start the Oozie server. You can also start the server manually with the
following command:

```
service oozie start
su -l oozie -c "/usr/hdp/current/oozie-server/bin/oozied.sh start"
```

Note, there is no need to clean a zombie pid file before starting the server.

    export default header: 'Oozie Server Start', handler: ({options}) ->

Wait for all the dependencies.

      @call 'masson/core/krb5_client/wait', once: true, options.wait_krb5_client
      @call '@rybajs/metal/zookeeper/server/wait', once: true, options.wait_zookeeper_server
      @call '@rybajs/metal/hadoop/hdfs_nn/wait', once: true, options.wait_hdfs_nn, conf_dir: options.hadoop_conf_dir
      @call '@rybajs/metal/hbase/master/wait', once: true, options.wait_hbase_master
      @call '@rybajs/metal/hive/hcatalog/wait', once: true, options.wait_hive_hcatalog
      @call '@rybajs/metal/hive/server2/wait', once: true, options.wait_hive_server2
      @call '@rybajs/metal/hive/webhcat/wait', once: true, options.wait_hive_webhcat

Start the service

      # @connection.wait
      #   host: oozie_ctx.config.host
      #   port: oozie_ctx.config.ryba.oozie.http_port
      #   unless: oozie_ctx.config.host is @config.host
      @service.start
        name: 'oozie'
