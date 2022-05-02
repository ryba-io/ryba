
# Hadoop HDFS SecondaryNameNode Start

    module.exports = []
    module.exports.push 'masson/bootstrap'
    # module.exports.push require('./index').configure

## Start Service

Start the HDFS NameNode Server. You can also start the server manually with the
following two commands:

```
service hadoop-hdfs-secondarynamenode start
su -l hdfs -c "/usr/hdp/current/hadoop-client/sbin/hadoop-daemon.sh --config /etc/hadoop/conf --script hdfs start secondarynamenode"
```

    module.exports.push header: 'HDFS SNN Start', label_true: 'STARTED', handler: ->
      @service.start
        name: 'hadoop-hdfs-secondarynamenode'
