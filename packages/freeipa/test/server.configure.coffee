
configure = require '../server/configure'

describe 'freeipa.server.configure', ->

  it 'normalize a minimal configuration', ->
    configure
      options:
        admin_password: 'abcdefgh'
        manager_password: 'abcdefgh'
        domain: 'domain.com'
        dns_email_manager: 'manager@domain.com'
        ssl_cert_file: 'path/to/cert/file'
        ssl_key_file: 'path/to/key/file'
      node: {}
      deps: {}
    .should.eql
      admin_password: 'abcdefgh'
      manager_password: 'abcdefgh'
      domain: 'domain.com'
      dns_email_manager: 'manager@domain.com'
      ssl_cert_file: 'path/to/cert/file'
      ssl_key_file: 'path/to/key/file'
      fqdn: undefined
      ip_address: undefined
      manage_users_groups: true
      hsqldb:
        group:
          name: 'hsqldb'
          system: true
        user:
          name: 'hsqldb'
          system: true
          gid: 'hsqldb'
          shell: false
          comment: 'LDAP User'
          home: '/var/lib/hsqldb'
      apache:
        group:
          name: 'apache'
          system: true
        user:
          name: 'apache'
          system: true
          gid: 'apache'
          shell: false
          comment: 'apache User'
          home: '/usr/share/httpd'
      memcached:
        group:
          name: 'memcached'
          system: true 
        user:
          name: 'memcached'
          system: true
          gid: 'memcached'
          shell: false
          comment: 'memcached User'
          home: '/run/memcached'
      ods:
        group:
          name: 'ods'
          system: true
        user:
          name: 'ods'
          system: true
          gid: 'ods'
          shell: false
          comment: 'ods User'
          home: '/var/lib/softhsm'
      tomcat:
        group:
          name: 'tomcat'
          system: true
        user:
          name: 'tomcat'
          system: true
          gid: 'tomcat'
          shell: false
          comment: 'tomcat User'
          home: '/usr/share/tomcat'
      pkiuser:
        group:
          name: 'pkiuser'
          system: true
        user:
          name: 'pkiuser'
          system: true
          gid: 'pkiuser'
          shell: false
          comment: 'pkiuser User'
          home: '/usr/share/pki'
      dirsrv:
        group:
          name: 'dirsrv'
          system: true 
        user:
          name: 'dirsrv',
          system: true,
          gid: 'dirsrv',
          shell: false,
          comment: 'dirsrv User',
          home: '/usr/share/dirsrv'
      iptables: undefined
      conf_dir: '/etc/freeipa/conf'
      dns_enabled: true
      dns: {}
      dns_auto_reverse: true
      dns_auto_forward: false
      dns_forwarder: []
      ntp_enabled: true
      realm_name: 'DOMAIN.COM'
      ssl_enabled: true
      ssl_key_local: true
      ssl_ca_cert_local: true
      admin:
        'DOMAIN.COM':
          realm: 'DOMAIN.COM'
          kadmin_principal: 'admin@DOMAIN.COM'
          kadmin_password: 'abcdefgh'
      wait: {}
