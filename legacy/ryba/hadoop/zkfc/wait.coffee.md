
# Hadoop ZKFC Wait

    export default header: 'HDFS ZKFC Wait', handler:  ->
      options = {}
      options.wait = for zkfc_ctx in @contexts '@rybajs/metal/hadoop/zkfc'
        host: zkfc_ctx.config.host, port: zkfc_ctx.config.ryba.hdfs.site['dfs.ha.zkfc.port']

      @connection.wait
        servers: options.wait
