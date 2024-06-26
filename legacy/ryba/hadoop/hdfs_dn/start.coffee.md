
# Hadoop HDFS DataNode Start

Start the DataNode service. It is recommended to start a DataNode after its associated
NameNodes. The DataNode doesn't wait for any NameNode to be started. Inside a
federated cluster, the DataNode may be dependant of multiple NameNode clusters
and some may be inactive.

    export default header: 'HDFS DN Start', handler: ({options}) ->

## Wait

Wait for the Kerberos server and Zookeeper server.

      @call once: true, 'masson/core/krb5_client/wait', options.wait_krb5_client
      @call once: true, '@rybajs/metal/zookeeper/server/wait', options.wait_zookeeper_server

## Service

You can also start the server manually with the following two commands:

```
system hadoop-hdfs-datanode start
systemctl start hadoop-hdfs-datanode
HADOOP_SECURE_DN_USER=hdfs /usr/hdp/current/hadoop-hdfs-datanode/../hadoop/sbin/hadoop-daemon.sh --config /etc/hadoop-hdfs-datanode/conf --script hdfs start datanode
```

      @service.start name: 'hadoop-hdfs-datanode'
