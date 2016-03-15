
# Hadoop Core Install

    module.exports = header: 'Hadoop Core Install', retry: 0, handler: ->
      {realm, hadoop_group, hdfs, yarn, mapred} = @config.ryba
      {ssl, ssl_server, ssl_client, hadoop_conf_dir} = @config.ryba
      {kadmin_principal, kadmin_password, admin_server} = @config.krb5.etc_krb5_conf.realms[realm]
    
## Users & Groups

By default, the "hadoop-client" package rely on the "hadoop", "hadoop-hdfs",
"hadoop-mapreduce" and "hadoop-yarn" dependencies and create the following
entries:

```bash
cat /etc/passwd | grep hadoop
hdfs:x:496:497:Hadoop HDFS:/var/lib/hadoop-hdfs:/bin/bash
yarn:x:495:495:Hadoop Yarn:/var/lib/hadoop-yarn:/bin/bash
mapred:x:494:494:Hadoop MapReduce:/var/lib/hadoop-mapreduce:/bin/bash
cat /etc/group | egrep "hdfs|yarn|mapred"
hadoop:x:498:hdfs,yarn,mapred
hdfs:x:497:
yarn:x:495:
mapred:x:494:
```

Note, the package "hadoop" will also install the "dbus" user and group which are
not handled here.

      @call header: 'Users & Groups', handler: ->
        @group [hadoop_group, hdfs.group, yarn.group, mapred.group]
        @user [hdfs.user, yarn.user, mapred.user]

## Topology

Configure the topology script to enable rack awareness to Hadoop.

      @call header: 'Topology', handler: ->
        h_ctxs = @contexts modules: ['ryba/hadoop/hdfs_dn', 'ryba/hadoop/yarn_nm']
        topology = []
        for h_ctx in h_ctxs
          rack = if h_ctx.config.ryba?.rack? then h_ctx.config.ryba.rack else ''
          # topology.push "#{host}  #{rack}"
          topology.push "#{h_ctx.config.ip}  #{rack}"
        topology = topology.join("\n")
        @upload
          destination: "#{hadoop_conf_dir}/rack_topology.sh"
          source: "#{__dirname}/../resources/rack_topology.sh"
          uid: hdfs.user.name
          gid: hadoop_group.name
          mode: 0o755
          backup: true
        @write
          destination: "#{hadoop_conf_dir}/rack_topology.data"
          content: topology
          uid: hdfs.user.name
          gid: hadoop_group.name
          mode: 0o755
          backup: true
          eof: true

## Kerberos HDFS User

Create the HDFS user principal. This will be the super administrator for the HDFS
filesystem. Note, we do not create a principal with a keytab to allow HDFS login
from multiple sessions with braking an active session.

      @call header: 'HDFS Client # Kerberos User', handler: ->
        @krb5_addprinc merge
          kadmin_principal: kadmin_principal
          kadmin_password: kadmin_password
          kadmin_server: admin_server
        , hdfs.krb5_user

## Test User

Create a Unix and Kerberos test user, by default "ryba". Its HDFS home directory
will be created by one of the datanode.

      @call header: 'User Test', handler: ->
        # ryba group and user may already exist in "/etc/passwd" or in any sssd backend
        {group, user, krb5_user} = @config.ryba
        @group group
        @user user
        @krb5_addprinc merge
          kadmin_principal: kadmin_principal
          kadmin_password: kadmin_password
          kadmin_server: admin_server
        , krb5_user

      @mkdir
        header: 'Keytabs'
        destination: '/etc/security/keytabs'
        uid: 'root'
        gid: 'root' # was hadoop_group.name
        mode: 0o0755

## SPNEGO

Create the SPNEGO service principal in the form of "HTTP/{host}@{realm}" and place its
keytab inside "/etc/security/keytabs/spnego.service.keytab" with ownerships set to "hdfs:hadoop"
and permissions set to "0660". We had to give read/write permission to the group because the
same keytab file is for now shared between hdfs and yarn services.

      @call header: 'SPNEGO', handler: ->
        @krb5_addprinc
          principal: "HTTP/#{@config.host}@#{realm}"
          randkey: true
          keytab: '/etc/security/keytabs/spnego.service.keytab'
          uid: hdfs.user.name
          gid: hadoop_group.name
          mode: 0o660 # need rw access for hadoop and mapred users
          kadmin_principal: kadmin_principal
          kadmin_password: kadmin_password
          kadmin_server: admin_server
        @execute # Validate keytab access by the hdfs user
          cmd: "su -l #{hdfs.user.name} -c \"klist -kt /etc/security/keytabs/spnego.service.keytab\""
          if: -> @status -1

      @call header: 'Compression', timeout: -1, handler: ->
        { hadoop_conf_dir } = @config.ryba
        @service name: 'snappy'
        @service name: 'snappy-devel'
        @execute
          cmd: 'ln -sf /usr/lib64/libsnappy.so /usr/lib/hadoop/lib/native/.'
          if: -> @status(-1) or @status(-2)
        @service
          name: 'lzo'
        @service
          name: 'lzo-devel'
        @service
          name: 'hadoop-lzo'
        @service
          name: 'hadoop-lzo-native'

## Web UI

This action follow the ["Authentication for Hadoop HTTP web-consoles"
recommendations](http://hadoop.apache.org/docs/r1.2.1/HttpAuthentication.html).

      @execute
        header: 'Web UI'
        cmd: 'dd if=/dev/urandom of=/etc/hadoop/hadoop-http-auth-signature-secret bs=1024 count=1'
        unless_exists: '/etc/hadoop/hadoop-http-auth-signature-secret'

## SSL

      @call header: 'SSL', retry: 0, handler: ->
        @hconfigure
          destination: "#{hadoop_conf_dir}/ssl-server.xml"
          properties: ssl_server
        @hconfigure
          destination: "#{hadoop_conf_dir}/ssl-client.xml"
          properties: ssl_client
        # Client: import certificate to all hosts
        @java_keystore_add
          keystore: ssl_client['ssl.client.truststore.location']
          storepass: ssl_client['ssl.client.truststore.password']
          caname: "hadoop_root_ca"
          cacert: "#{ssl.cacert}"
          local_source: true
        # Server: import certificates, private and public keys to hosts with a server
        @java_keystore_add
          keystore: ssl_server['ssl.server.keystore.location']
          storepass: ssl_server['ssl.server.keystore.password']
          caname: "hadoop_root_ca"
          cacert: "#{ssl.cacert}"
          key: "#{ssl.key}"
          cert: "#{ssl.cert}"
          keypass: ssl_server['ssl.server.keystore.keypassword']
          name: @config.shortname
          local_source: true
        @java_keystore_add
          keystore: ssl_server['ssl.server.keystore.location']
          storepass: ssl_server['ssl.server.keystore.password']
          caname: "hadoop_root_ca"
          cacert: "#{ssl.cacert}"
          local_source: true

## Dependencies

    {merge} = require 'mecano/lib/misc'