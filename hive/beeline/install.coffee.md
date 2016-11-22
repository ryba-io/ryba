
# Hive & HCatalog Client

    module.exports = header: 'Hive Client Install', handler: ->
      {hive, hadoop_group} = @config.ryba
      {java_home} =@config.java
      {ssl, ssl_server, ssl_client, hadoop_conf_dir} = @config.ryba
      tmp_location = "/var/tmp/ryba/ssl"

## Register

      @registry.register 'hconfigure', 'ryba/lib/hconfigure'
      @registry.register 'hdp_select', 'ryba/lib/hdp_select'


## Service

      @service
        name: 'hive'
      @hdp_select 'hive-webhcat'

## SSL

      @java_keystore_add
        header: 'Client SSL'
        keystore: hive.client.truststore_location
        storepass: hive.client.truststore_password
        caname: "hive_root_ca"
        cacert: ssl.cacert
        local_source: true

## Dependencies

    path = require 'path'