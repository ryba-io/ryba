
# Hadoop HDFS Secondary NameNode Status

## Status

Check if the HDFS Secondary NameNode server is running. The process ID is
located by default inside "/var/run/hadoop-hdfs/hdfs/hadoop-hdfs-secondarynamenode.pid".

    export default header: 'HDFS SNN Status', handler: ->
      @service.status
        cmd: 'hadoop-hdfs-secondarynamenode'
