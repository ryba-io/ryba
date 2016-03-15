
# Hive Client Configuration

Example:

```json
{
  "ryba": {
    "hive": {
      "client": {
        opts": "-Xmx4096m",
        heapsize": "1024"
      }
    }
  }
}
```

    module.exports = handler: ->
      [hcat_ctx] = @contexts 'ryba/hive/hcatalog', [ require('ryba/commons/db_admin').handler, require('../hcatalog/configure').handler]
      throw Error "No HCatalog server declared" unless hcat_ctx
      # require('../../tez/configure').handler.call @
      {mapred, tez} = @config.ryba 
      hive = @config.ryba.hive ?= {}
      hive.client ?= {}
      hive.client.opts = ""
      hive.client.heapsize = 1024
      hive.conf_dir ?= '/etc/hive/conf'

## Users & Groups
      # User
      hive.user ?= {}
      hive.user = name: hive.user if typeof hive.user is 'string'
      hive.user.name  = hcat_ctx.config.ryba.hive.user.name ?= 'hive'
      hive.user.system =  hcat_ctx.config.ryba.hive.user.system ?= true
      hive.user.groups = hcat_ctx.config.ryba.hive.user.groups ?= 'hadoop'
      hive.user.comment = hcat_ctx.config.ryba.hive.user.comment ?= 'Hive User'
      hive.user.home = hcat_ctx.config.ryba.hive.user.home ?= '/var/lib/hive'
      hive.user.limits ?= {}
      hive.user.limits.nofile = hcat_ctx.config.ryba.hive.user.limits.nofile ?= 64000
      hive.user.limits.nproc = hcat_ctx.config.ryba.hive.user.limits.nproc ?= true
      # Group
      hive.group ?= {}
      hive.group = name: hive.group if typeof hive.group is 'string'
      hive.group.name = hcat_ctx.config.ryba.hive.group.name ?= 'hive'
      hive.group.system = hcat_ctx.config.ryba.hive.group.system ?= true
      hive.user.gid = hive.group.name

## Configuration

      hive.aux_jars = hcat_ctx.config.ryba.hive.aux_jars ?= []
      hive.site ?= {}
      # Tuning
      # [Christian Prokopp comments](http://www.quora.com/What-are-the-best-practices-for-using-Hive-What-settings-should-we-enable-most-of-the-time)
      # [David Streever](https://streever.atlassian.net/wiki/display/HADOOP/Hive+Performance+Tips)
      # hive.site['hive.exec.compress.output'] ?= 'true'
      hive.site['hive.exec.compress.intermediate'] ?= 'true'
      hive.site['hive.auto.convert.join'] ?= 'true'
      hive.site['hive.cli.print.header'] ?= 'false'
      # hive.site['hive.mapjoin.smalltable.filesize'] ?= '50000000'

      hive.site['hive.execution.engine'] ?= 'tez'
      hive.site['hive.tez.container.size'] ?= tez.site['tez.am.resource.memory.mb']
      hive.site['hive.tez.java.opts'] ?= tez.site['hive.tez.java.opts']
      # Size per reducer. The default in Hive 0.14.0 and earlier is 1 GB. In
      # Hive 0.14.0 and later the default is 256 MB.
      # HDP set it to 64 MB which seems wrong
      # Don't know if this default value should be hardcoded or estimated based
      # on cluster capacity 
      hive.site['hive.exec.reducers.bytes.per.reducer'] ?= '268435456'

      # Import HCatalog properties

      # properties = [
      #   'hive.metastore.uris'
      #   'hive.security.authorization.enabled'
      #   'hive.server2.authentication'
      #   # 'hive.security.authorization.manager'
      #   # 'hive.security.metastore.authorization.manager'
      #   # 'hive.security.authenticator.manager'
      #   # Transaction, read/write locks
      #   'hive.support.concurrency'
      #   'hive.zookeeper.quorum'
      #   'hive.enforce.bucketing'
      #   'hive.exec.dynamic.partition.mode'
      #   'hive.txn.manager'
      #   'hive.txn.timeout'
      #   'hive.txn.max.open.batch'
      #   'hive.cluster.delegation.token.store.zookeeper.connectString'
      #   'hive.cluster.delegation.token.store.class'
      # ]
      # 
      # for property in properties then hive.site[property] ?= hcat_ctx.config.ryba.hive.site[property]
      
## Client Metastore Configuration

      for property in  [
        'hive.metastore.uris'
        'hive.security.authorization.enabled'
        'hive.server2.authentication'
        # 'hive.security.authorization.manager'
        # 'hive.security.metastore.authorization.manager'
        # 'hive.security.authenticator.manager'
        # Transaction, read/write locks
        'hive.support.concurrency'
        'hive.zookeeper.quorum'
        'hive.enforce.bucketing'
        'hive.exec.dynamic.partition.mode'
        'hive.txn.manager'
        'hive.txn.timeout'
        'hive.txn.max.open.batch'
        'hive.cluster.delegation.token.store.zookeeper.connectString'
        'hive.cluster.delegation.token.store.class'
        'hive.metastore.local'
        'fs.hdfs.impl.disable.cache'
        'hive.server2.thrift.sasl.qop'
        'hive.metastore.sasl.enabled'
        'hive.metastore.cache.pinobjtypes'
        # 'hive.metastore.kerberos.keytab.file'
        'hive.metastore.kerberos.principal'
        'hive.security.metastore.authorization.manager'
        'hive.security.authenticator.manager'
        'hive.security.metastore.authenticator.manager'
        'hive.metastore.pre.event.listeners'
        'hive.optimize.mapjoin.mapreduce'
        'hive.heapsize'
        'hive.auto.convert.sortmerge.join.noconditionaltask'
        'hive.exec.max.created.files'
        'javax.jdo.option.ConnectionURL'
        # 'hive.security.authorization.manager'
        # 'hive.security.metastore.authorization.manager'
        # 'hive.security.authenticator.manager'
        # Transaction, read/write locks
      ] then hive.site[property] ?= hcat_ctx.config.ryba.hive.site[property]
      # Remove password from client configuration
      unless @has_module 'ryba/hive/hcatalog' or @has_module 'ryba/hive/server2'
        hive.site['javax.jdo.option.ConnectionUserName']= null
        hive.site['javax.jdo.option.ConnectionPassword'] = null

## Configure SSL

      hive.client.truststore_location ?= "#{hive.conf_dir}/truststore"
      hive.client.truststore_password ?= "ryba123"


## Notes

Example of a minimal client configuration:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
  <property>
    <name>hive.metastore.kerberos.keytab.file</name>
    <value>/etc/security/keytabs/hive.service.keytab</value>
  </property>
  <property>
    <name>hive.metastore.kerberos.principal</name>
    <value>hive/_HOST@ADALTAS.COM</value>
  </property>
  <property>
    <name>hive.metastore.sasl.enabled</name>
    <value>true</value>
  </property>
  <property>
    <name>hive.metastore.uris</name>
    <value>thrift://big3.big:9083</value>
  </property>
</configuration>
```