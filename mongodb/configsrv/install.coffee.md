
# MongoDB Config Server Install

    module.exports =  header: 'MongoDB Config Server Install', handler: ->
      {mongodb, realm, ssl} = @config.ryba
      {configsrv} = mongodb
      krb5 = @config.krb5_client.admin[realm]

## IPTables

| Service       | Port  | Proto | Parameter       |
|---------------|-------|-------|-----------------|
| Mongod        | 27017 |  tcp  |  configsrv.port |

IPTables rules are only inserted if the parameter "iptables.action" is set to
"start" (default value).

      @call header: 'IPTables', ->
        @tools.iptables
          rules: [
            { chain: 'INPUT', jump: 'ACCEPT', dport: configsrv.config.net.port, protocol: 'tcp', state: 'NEW', comment: "MongoDB Config Server port" }
          ]
          if: @config.iptables.action is 'start'

## Identities

      @system.group header: 'Group', mongodb.group
      @system.user header: 'User', mongodb.user

## Packages

Install mongodb-org-server containing packages for a mongod service. We render the init scripts
in order to rendered configuration file with custom properties.

      @call header: 'Packages', ->
        @service name: 'mongodb-org-server'
        @service name: 'mongodb-org-shell'
        @service name: 'mongodb-org-tools'
        @service.init
          if_os: name: ['redhat','centos'], version: '6'
          source: "#{__dirname}/../resources/mongod-config-server.j2"
          target: '/etc/init.d/mongod-config-server'
          context: @config
          mode: 0o0750
          local: true
          eof: true
        @call
          if_os: name: ['redhat','centos'], version: '7'
        , ->
          @service.init
            source: "#{__dirname}/../resources/mongod-config-server-redhat-7.j2"
            target: '/usr/lib/systemd/system/mongod-config-server.service'
            context: @config
            mode: 0o0640
            local: true
            eof: true
          @system.tmpfs
            mount: mongodb.configsrv.pid_dir
            uid: mongodb.user.name
            gid: mongodb.group.name
            perm: '0750'
          @service.startup
            name: 'mongod-config-server'


## Layout

Create dir where the mongodb-config-server stores its metadata

      @call header: 'Layout', ->
        @system.mkdir
          target: '/var/lib/mongodb'
          uid: mongodb.user.name
          gid: mongodb.group.name
        @system.mkdir
          target: mongodb.configsrv.config.storage.dbPath
          uid: mongodb.user.name
          gid: mongodb.group.name
        @system.mkdir
          if: mongodb.configsrv.config.storage.repairPath?
          target: mongodb.configsrv.config.storage.repairPath
          uid: mongodb.user.name
          gid: mongodb.group.name
        @system.mkdir
          target: mongodb.configsrv.config.net.unixDomainSocket.pathPrefix
          uid: mongodb.user.name
          gid: mongodb.group.name

## Configure

Configuration file for mongodb config server.

      @call header: 'Configure', ->
        @file.yaml
          target: "#{mongodb.configsrv.conf_dir}/mongod.conf"
          content: mongodb.configsrv.config
          merge: false
          uid: mongodb.user.name
          gid: mongodb.group.name
          mode: 0o0750
          backup: true
        @service.stop
          if: -> @status -1
          name: 'mongod-config-server'

## SSL

Mongod service requires to have in a single file the private key and the certificate
with pem file. So we append to the file the private key and certficate.

      @call header: 'SSL', ->
        @file.download
          source: ssl.cacert
          target: "#{mongodb.configsrv.conf_dir}/cacert.pem"
          uid: mongodb.user.name
          gid: mongodb.group.name
        @file.download
          source: ssl.key
          target: "#{mongodb.configsrv.conf_dir}/key_file.pem"
          uid: mongodb.user.name
          gid: mongodb.group.name
        @file.download
          source: ssl.cert
          target: "#{mongodb.configsrv.conf_dir}/cert_file.pem"
          uid: mongodb.user.name
          gid: mongodb.group.name
        @file
          source: "#{mongodb.configsrv.conf_dir}/cert_file.pem"
          target: "#{mongodb.configsrv.conf_dir}/key.pem"
          append: true
          backup: true
          eof: true
          uid: mongodb.user.name
          gid: mongodb.group.name
        @file
          source: "#{mongodb.configsrv.conf_dir}/key_file.pem"
          target: "#{mongodb.configsrv.conf_dir}/key.pem"
          eof: true
          append: true
          uid: mongodb.user.name
          gid: mongodb.group.name

## Kerberos

      @krb5.addprinc krb5,
        header: 'Kerberos Admin'
        principal: "#{mongodb.configsrv.config.security.sasl.serviceName}"#/#{@config.host}@#{realm}"
        password: mongodb.configsrv.sasl_password

# User limits

      @system.limits
        header: 'User Limits'
        user: mongodb.user.name
      , mongodb.user.limits
