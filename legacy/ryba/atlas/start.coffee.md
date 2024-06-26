
# Altas Metadata Server Start

Apache Atlas Needs the following components to be started.
- HBase
- Hive Server2
- Kafka Brokers
- Ranger Admin
- Solr Cloud

    export default header: 'Atlas Start', handler: (options) ->

Wait for Kerberos, HBase, Hive, Kafka and Ranger.

      @call 'masson/core/krb5_client/wait', once: true, options.wait_krb5_client
      @call '@rybajs/metal/hbase/regionserver/wait', once: true, options.wait_hbase
      @call '@rybajs/metal/kafka/broker/wait', once: true, options.wait_kafka
      @call '@rybajs/metal/ranger/admin/wait', once: true, options.wait_ranger
      
      @connection.wait
        if: options.solr_type is 'cloud_docker'
        host: options.solr.cluster_config['master']
        port: options.solr.cluster_config['port']

## Start the service
You can start the service with the following commands.
* Centos/REHL 6
```
  service atlas-metadata-server start
```
* Centos/REHL 6
```
  systemctl start atlas-metadata-server
```

      @service.start
        name: 'atlas-metadata-server'
