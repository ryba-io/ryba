
# Ambari Server Install

See the Ambari documentation relative to [Software Requirements][sr] before
executing this module.

    export default header: 'Ambari Server Install', handler: ({options}) ->

## Identities

By default, the "ambari-server" package does not create any identities.

      @system.group header: 'Group', options.group
      @system.group header: 'Group Hadoop', options.hadoop_group
      @system.user header: 'User', options.user

## IPTables

| Service       | Port  | Proto | Parameter       |
|---------------|-------|-------|-----------------|
| Ambari Server | 8080  |  tcp  |  HTTP Port      |
| Ambari Server | 8842  |  tcp  |  HTTPS Port     |

IPTables rules are only inserted if the parameter "iptables.action" is set to
"start" (default value).

      port = options.config[unless options.config['api.ssl'] then 'client.api.port' else 'client.api.ssl.port']
      @tools.iptables
        rules: [
          { chain: 'INPUT', jump: 'ACCEPT', dport: port, protocol: 'tcp', state: 'NEW', comment: "Ambari REST SSL" }
        ]
        if: options.iptables

## Package & Repository

Declare the Ambari custom repository.
Install Ambari server package.

      @service
        header: 'Package'
        name: 'ambari-server'
        startup: true
      @service
        header: 'Mysql Connector'
        name: 'mysql-connector-java'
        if: options.db.engine is 'mysql'

## Non-Root

      @file
        header: 'Sudo'
        if: options.sudo
        target: '/etc/sudoers.d/ambari_server'
        content: """
        # Ambari Commands
        ambari ALL=(ALL) NOPASSWD:SETENV: /bin/mkdir -p /etc/security/keytabs, /bin/chmod * /etc/security/keytabs/*.keytab, /bin/chown * /etc/security/keytabs/*.keytab, /bin/chgrp * /etc/security/keytabs/*.keytab, /bin/rm -f /etc/security/keytabs/*.keytab, /bin/cp -p -f /var/lib/ambari-server/data/tmp/* /etc/security/keytabs/*.keytab
        Defaults exempt_group = ambari
        Defaults !env_reset,env_delete-=PATH
        Defaults: ambari !requiretty
        """
      @system.remove
        header: 'Clean Sudo'
        unless: options.sudo
        target: '/etc/sudoers.d/ambari_server'

## Database

Prepare the Ambari Database.

      @call header: 'DB', ->

Wait for database to listen

        @call '@rybajs/metal/commons/db_admin/wait', once: true, options.wait_db_admin

Password is stored inside a file which location is referenced by the property
"server.jdbc.user.passwd" in the configuration file. The permissione "660" match
the ones generated by "ambari-server setup".

        @file
          header: 'Stash Password'
          unless: options.master_key
          target: options.config['server.jdbc.user.passwd']
          content: options.db.password
          backup: true
          mode: 0o0640
        # Note, for same reason, `ambari-server setup-security` keep re-generating
        # the stashed password file even if it uses the encrypted database located
        # in "/var/lib/ambari-sever/keys".
        # @system.remove
        #   header: 'Clean Stash Password'
        #   if: options.master_key
        #   target: '/etc/ambari-server/conf/password.dat'

Create the database hosting the Ambari data with restrictive user permissions.

        @db.user options.db, database: null,
          header: 'User'
          if: options.db.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db,
          header: 'Database'
          user: options.db.username
          if: options.db.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db,
          header: 'Schema'
          if: options.db.engine is 'postgresql'
          schema: options.db.schema or options.db.database
          database: options.db.database
          owner: options.db.username

Load the database with initial data

        switch options.db.engine
          when 'mysql', 'mariadb'
            load = db.cmd(options.db, null) + '< /var/lib/ambari-server/resources/Ambari-DDL-MySQL-CREATE.sql'
            created = db.cmd(options.db, 'show tables') + '|  grep clusters'
          when 'postgresql'
            load = db.cmd(options.db, null) + '< /var/lib/ambari-server/resources/Ambari-DDL-Postgres-CREATE.sql'
            created = db.cmd(options.db, null) + 'show tables |  grep clusters'
        @system.execute
          header: 'Init'
          cmd: load
          unless_exec: created

## Hive DB

      @call header: 'Hive DB', if: !!options.db_hive, ->
        @db.user options.db_hive, database: null,
          header: 'User'
          if: options.db_hive.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db_hive,
          header: 'Database'
          user: options.db_hive.username
          if: options.db_hive.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db_hive,
          header: 'Schema'
          if: options.db_hive.engine is 'postgresql'
          schema: options.db_hive.schema or options.db_hive.database
          database: options.db_hive.database
          owner: options.db_hive.username

## Oozie DB

      @call header: 'Oozie DB', if: !!options.db_oozie, ->
        @db.user options.db_oozie, database: null,
          header: 'User'
          if: options.db_oozie.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db_oozie,
          header: 'Database'
          user: options.db_oozie.username
          if: options.db_oozie.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db_oozie,
          header: 'Schema'
          if: options.db_oozie.engine is 'postgresql'
          schema: options.db_oozie.schema or options.db_oozie.database
          database: options.db_oozie.database
          owner: options.db_oozie.username

## Ranger DB

      @call header: 'Ranger DB', if: !!options.db_ranger, ->
        @db.user options.db_ranger, database: null,
          header: 'User'
          if: options.db_ranger.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db_ranger,
          header: 'Database'
          user: options.db_ranger.username
          if: options.db_ranger.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db_ranger,
          header: 'Schema'
          if: options.db_ranger.engine is 'postgresql'
          schema: options.db_ranger.schema or options.db_ranger.database
          database: options.db_ranger.database
          owner: options.db_ranger.username

## Hive DB

      @call header: 'Hive DB', if: !!options.db_hive, ->
        @db.user options.db_hive, database: null,
          header: 'User'
          if: options.db_hive.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db_hive,
          header: 'Database'
          user: options.db_hive.username
          if: options.db_hive.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db_hive,
          header: 'Schema'
          if: options.db_hive.engine is 'postgresql'
          schema: options.db_hive.schema or options.db_hive.database
          database: options.db_hive.database
          owner: options.db_hive.username

## Oozie DB

      @call header: 'Oozie DB', if: !!options.db_oozie, ->
        @db.user options.db_oozie, database: null,
          header: 'User'
          if: options.db_oozie.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db_oozie,
          header: 'Database'
          user: options.db_oozie.username
          if: options.db_oozie.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db_oozie,
          header: 'Schema'
          if: options.db_oozie.engine is 'postgresql'
          schema: options.db_oozie.schema or options.db_oozie.database
          database: options.db_oozie.database
          owner: options.db_oozie.username

## Ranger DB

      @call header: 'Ranger DB', if: !!options.db_ranger, ->
        @db.user options.db_ranger, database: null,
          header: 'User'
          if: options.db_ranger.engine in ['mysql', 'mariadb', 'postgresql']
        @db.database options.db_ranger,
          header: 'Database'
          user: options.db_ranger.username
          if: options.db_ranger.engine in ['mysql', 'mariadb', 'postgresql']
        @db.schema options.db_ranger,
          header: 'Schema'
          if: options.db_ranger.engine is 'postgresql'
          schema: options.db_ranger.schema or options.db_ranger.database
          database: options.db_ranger.database
          owner: options.db_ranger.username

## Configuration

Merge used defined configuration. This could be used to set up 
LDAP or Active Directory Authentication. The permissions "644" are the ones 
generated by the "ambari-server setup" command.

      @file.properties
        header: 'Config'
        target: "#{options.conf_dir}/ambari.properties"
        content: options.config
        merge: true
        comment: true
        backup: true
        mode: 0o0644

## Upload SSL Cert & Key

Upload and register the SSL certificate and private key respectively defined
by the "ssl.cert" and "ssl.key".

The public certificate is generated with the same permission and ownership as 
with the `ambari-server setup-security` command: user "root", group "ambari" 
and mode "644".

Restrictive ownership and permission are enforced on the private key. We might
want to move it into a different location (eg "/etc/security/certs") as
Ambari will store and work on a copy.

      @call header: 'SSL', ->
        @file
          header: 'Cert'
          source: options.ssl.cert.source
          local: options.ssl.cert.local
          target: "#{options.conf_dir}/cert.pem"
          uid: 'root'
          gid: options.group.name
          mode: 0o0644
        @file
          header: 'Key'
          source: options.ssl.key.source
          local: options.ssl.key.local
          target: "#{options.conf_dir}/key.pem"
          mode: 0o0600
        @file
          header: 'CACert'
          source: options.ssl.cacert.source
          local: options.ssl.cacert.local
          target: "#{options.conf_dir}/cacert.pem"
          mode: 0o0644
        @java.keystore_add
          keystore: "#{options.truststore.target}"
          storepass: "#{options.truststore.password}"
          caname: "#{options.truststore.caname}"
          cacert: "#{options.conf_dir}/cacert.pem"

## JAAS

Note, Ambari will change ownership to root.

      @krb5.addprinc options.krb5.admin,
        header: 'JAAS'
        if: options.jaas?.enabled
        principal: options.jaas.principal.replace '_HOST', options.fqdn
        keytab: options.jaas.keytab
        randkey: true
        uid: 'root'
        gid: options.group.name
        mode: 0o660

## MPack

      for name, mpack of options.mpacks
        mpack.target ?= "/var/tmp/#{path.basename mpack.source}"
        mpack.purge ?= true
        @file.download
          header: "Download #{name}"
          if: mpack.enabled
          source: mpack.source
          target: mpack.target
        @system.execute
          header: "Register #{name}"
          if: mpack.enabled
          unless_exists: "/var/lib/ambari-server/resources/mpacks/#{path.basename mpack.source, '.tar.gz'}"
          cmd: """
          yes | ambari-server install-mpack \
            --mpack=#{mpack.target} \
            #{if mpack.purge then '--purge' else ''} --verbose
          """

## Setup

Password encryption is activated if the property "master_key" is configured. By 
default the passwords to access the Ambari database and the LDAP server are 
stored in a plain text configuration file. if Password encryption is activated, 
Ambari will store information inside "/var/lib/ambari-server/keys".

Be carefull, notes from Ambari 2.4.2:
* Options "jdbc-db" and "jdbc-driver" prevent the setup script from modifying 
  the properties file.
* Option "cluster-name" does nothing

      @call header: 'Setup', ->
        props = {}
        # @call (options, callback) ->
        #   ssh = @ssh options.ssh
        #   properties ssh, '/etc/ambari-server/conf/ambari.properties', {}, (err, data) ->
        #     throw err if err
        #     for k, v of data
        #       props[k] ?= {}
        #       props[k].org = v
        #     callback()
        @system.execute
          shy: true
          cmd: """
          ambari-server setup \
            -s \
            -j #{options.java_home} \
            --database=#{if options.db.engine in ['mysql','mariadb'] then 'mysql' else options.db.engine  } \
            --databasehost=#{options.db.host} \
            --databaseport=#{options.db.port} \
            --databasename=#{options.db.database} \
            --databaseusername=#{options.db.username} \
            --databasepassword=#{options.db.password} \
            --enable-lzo-under-gpl-license
          ambari-server setup \
            --jdbc-db=mysql \
            --jdbc-driver=/usr/share/java/mysql-connector-java.jar
          [ -n "#{options.master_key}" ] && ambari-server setup-security \
            --security-option=encrypt-passwords \
            --master-key=#{options.master_key} \
            --master-key-persist=true
          # --cluster-name=#{options.cluster_name}
          """
        @system.execute
          # if: options.config['api.ssl'] is 'true'
          shy: true
          cmd: """
          ambari-server setup-security \
            --security-option=setup-https \
            --api-ssl=#{options.config['api.ssl']} \
            --api-ssl-port=#{options.config['client.api.ssl.port']} \
            --pem-password= \
            --import-cert-path="#{options.conf_dir}/cert.pem" \
            --import-key-path="#{options.conf_dir}/key.pem"
          """
        @system.execute
          shy: true
          cmd: """
          ambari-server setup-security \
            --security-option=setup-truststore \
            --truststore-path=#{options.truststore.target} \
            --truststore-type=#{options.truststore.type} \
            --truststore-password=#{options.truststore.password} \
            --truststore-reconfigure
          """
        @system.execute
          shy: true
          if: options.jaas?.enabled
          cmd: """
          ambari-server setup-security \
            --security-option=setup-kerberos-jaas \
            --jaas-principal="#{options.jaas?.principal}" \
            --jaas-keytab="#{options.jaas?.keytab}"
          """
        # @call (_, callback) ->
        #   ssh = @ssh options.ssh
        #   properties ssh, '/etc/ambari-server/conf/ambari.properties', {}, (err, data) ->
        #     throw err if err
        #     for k, v of data
        #       props[k] ?= {}
        #       props[k].new = v
        #     callback()
        @call (_, callback) ->
          status = false
          for k, v of props
            if v.org isnt v.new
              @log message: "Option #{k} was #{JSON.stringify v.org} and is now #{JSON.stringify v.new}", level: 'INFO', module: '@rybajs/metal/lib/file/properties' unless v.org is v.new
              status = true
          callback null, status

## Start

Start the service or restart it if there were any changes.

      @service
        header: 'Start'
        name: 'ambari-server'
        state: ['started', 'restarted']
        if: -> @status()
      @call '@rybajs/metal/ambari/server/wait', once: true, options.wait

## Admin Credentials

      checkurl = url.format
        protocol: unless options.config['api.ssl'] then 'http' else 'https'
        hostname: options.fqdn
        port: options.config[unless options.config['api.ssl'] then 'client.api.port' else 'client.api.ssl.port']
        pathname: '/api/v1/clusters'
      changeurl = url.format
        protocol: unless options.config['api.ssl'] then 'http' else 'https'
        hostname: options.fqdn
        port: options.config[unless options.config['api.ssl'] then 'client.api.port' else 'client.api.ssl.port']
        pathname: '/api/v1/users/admin'
      cred = "admin:#{options.current_admin_password}"
      json = JSON.stringify "Users":
        "user_name": "admin"
        "password": "#{options.admin_password}"
        "old_password": "#{options.current_admin_password}"
      @system.execute
        header: 'Admin Credentials'
        if_exec: """
        curl -f -k -u #{cred} #{checkurl}
        """
        cmd: """
        curl -f -k -i -u #{cred} -H "X-Requested-By: ambari" -X PUT -d '#{json}' #{changeurl}
        """

## Dependencies

    path = require 'path'
    url = require 'url'
    misc = require '@nikitajs/core/lib/misc'
    db = require '@nikitajs/core/lib/misc/db'
    properties = require '@nikitajs/core/lib/file/properties/read'

[sr]: http://docs.hortonworks.com/HDPDocuments/Ambari-2.2.2.0/bk_Installing_HDP_AMB/content/_meet_minimum_system_requirements.html
