
# Druid Broker Server

[Druid](http://www.druid.io) is a high-performance, column-oriented, distributed 
data store.

    module.exports = ->
      'prepare':
        'ryba/druid/prepare'
      'configure': [
        'ryba/commons/db_admin'
        'ryba/druid/broker/configure'
      ]
      'install': [
        'masson/commons/java'
        'ryba/hadoop/hdfs_client'
        'ryba/hadoop/mapred_client'
        'ryba/druid/broker/install'
        'ryba/druid/broker/start'
      ]
      'start':
        'ryba/druid/broker/start'
      'status':
        'ryba/druid/broker/status'
      'stop':
        'ryba/druid/broker/stop'