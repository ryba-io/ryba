
# Hadoop HDFS DataNode Wait

    export default header: 'HDFS DN Wait', handler: ({options}) ->

## Wait for all datanode IPC Ports

Port is defined in the "dfs.datanode.address" property of hdfs-site. The default
value is 50020.

      @connection.wait
        header: 'IPC'
        servers: options.ipc

## Wait for all datanode HTTP Ports

Port is defined in the "dfs.datanode.https.address" property of hdfs-site. The default
value is 9865.

      @connection.wait
        header: 'HTTP'
        servers: options.http
