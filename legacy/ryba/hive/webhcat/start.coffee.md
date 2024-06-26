
# WebHCat Start

Run the command `./bin/ryba start -m @rybajs/metal/hive/webhcat` to start the WebHCat
server using Ryba.

By default, the pid of the running server is stored in
"/var/run/webhcat/webhcat.pid".


    export default header: 'WebHCat Start', handler: ({options}) ->

## Wait

Wait for Kerberos, Zookeeper, Hadoop and Hive HCatalog.

      @call 'masson/core/krb5_client/wait', once: true, options.wait_krb5_client
      @call '@rybajs/metal/zookeeper/server/wait', once: true, options.wait_zookeeper_server
      @call '@rybajs/metal/hive/hcatalog/wait', once: true, options.wait_hive_hcatalog

## Service

Start the WebHCat server. You can also start the server manually with one of the
following two commands:

```
service hive-webhcat-server start
systemctl start hive-webhcat-server
su -l hive -c "/usr/hdp/current/hive-webhcat/sbin/webhcat_server.sh start"
```

      @service.start header: 'Service', 'hive-webhcat-server'
