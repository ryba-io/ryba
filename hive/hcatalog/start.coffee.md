
# Hive HCatalog Start


## Start Hive HCatalog

Start the Hive HCatalog server. You can also start the server manually with the
following two commands:

```
service hive-hcatalog-server start
su -l hive -c 'nohup hive --service metastore >/var/log/hive-hcatalog/hcat.out 2>/var/log/hive-hcatalog/hcat.err & echo $! >/var/lib/hive-hcatalog/hcat.pid'
```

    module.exports =  header: 'Hive HCatalog Start', label_true: 'STARTED', handler: ->
      {hive} = @config.ryba
      jdbc = db.jdbc hive.hcatalog.site['javax.jdo.option.ConnectionURL']

## Wait

      @call once: true, 'masson/core/krb5_client/wait'
      @call once: true, 'ryba/hadoop/hdfs_nn/wait'
      @call once: true, 'ryba/zookeeper/server/wait'

## Wait Database

The Hive HCatalog require the database server to be started. The Hive Server2
require the HDFS Namenode to be started. Both of them will need to functionnal
HDFS server to answer queries.

      @call header: 'Wait DB', label_true: 'READY', ->
        @connection.wait jdbc.addresses

      @service.start
        header: 'Start service'
        label_true: 'STARTED'
        name: 'hive-hcatalog-server'

# Module Dependencies

    db = require 'nikita/lib/misc/db'
