
# Hadoop HDFS JournalNode Wait

Exemple:

```
nikita.hadoop.hdfs_jn.wait({
    rpc: [
      { "host": "master1.ryba", "port": "8485" },
      { "host": "master2.ryba", "port": "8485" },
      { "host": "master3.ryba", "port": "8485" },
    ]
})
```

    export default header: 'HDFS JN Wait', handler: ({options}) ->

      @connection.wait
        servers: options.rpc
