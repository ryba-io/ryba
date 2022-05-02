---
title: Kerberos with OpenLDAP Back-End
module: phyla/core/krb5_server
layout: module
---

## Kerberos with OpenLDAP Back-End

Usefull server commands:
*   Backup the db: `kdb5_util dump /path/to/dumpfile`
*   Initialize realm: `kdb5_ldap_util -D "cn=Manager,dc=adaltas,dc=com" -w test create -subtrees "ou=kerberos,ou=services,dc=adaltas,dc=com" -r ADALTAS.COM -s -P test`
*   Load the db: `kdb5_util load -update /path/to/dumpfile`
*   Stash password: `kdb5_ldap_util -D "cn=Manager,dc=adaltas,dc=com" -w test stashsrvpw -f /etc/krb5.d/stash.keyfile cn=krbadmin,ou=users,dc=adaltas,dc=com`

Resources:
*   [Kerberos with LDAP backend on centos](http://itdavid.blogspot.fr/2012/05/howto-centos-62-kerberos-kdc-with.html)
*   [Propagation](http://www-old.grantcohoe.com/guides/services/krb5-kdc)
*   [Replication](http://tldp.org/HOWTO/Kerberos-Infrastructure-HOWTO/server-replication.html)
*   [Kerberos with LDAP backend on ubuntu](http://labs.opinsys.com/blog/2010/02/05/setting-up-openldap-kerberos-on-ubuntu-10-04-lucid/)

    each = require 'each'
    misc = require 'mecano/lib/misc'
    module.exports = []

    module.exports.push 'phyla/bootstrap'
    module.exports.push 'phyla/core/openldap_client'
    module.exports.push 'phyla/core/yum'

## Configuration

*   `krb5_server.{realm}.ldap_manager_dn` (string)   
    The LDAP user with read and write access to the realm dn
    defined by the `ldap_realms_dn` property. Default to the 
    `openldap_krb5.manager_dn` property if you have one OpenLDAP server with 
    kerberos support declared inside the cluster by the 
    "phyla/core/openldap\_server\_krb5" module, otherwise required.      
*   `krb5_server.{realm}.ldap_manager_password` (string)   
    The password of the LDAP user with read and write access to the realm dn
    defined by the `ldap_realms_dn` property. Default to the 
    `openldap_krb5.manager_password` property if you have one OpenLDAP server with 
    kerberos support declared inside the cluster by the 
    "phyla/core/openldap\_server\_krb5" module, otherwise required.      
*   `krb5_server.{realm}.ldap_realms_dn` (string)   
    The location where to store the realms inside the LDAP tree. Default to the 
    `openldap_krb5.realms_dn` property if you have one OpenLDAP server with 
    kerberos support declared inside the cluster by the 
    "phyla/core/openldap\_server\_krb5" module, otherwise required.   

Example:

```json
{
  "krb5": {
    "ADALTAS.COM": {
      "kdc": "master3.hadoop",
      "kadmin_server": "master3.hadoop",
      "kadmin_principal": "wdavidw/admin@ADALTAS.COM",
      "kadmin_password": "test",
      "ldap\_kerberos\_container_dn": "ou=kerberos,dc=adaltas,dc=com",
      "ldap\_kdc\_dn": "cn=krbadmin,ou=users,dc=adaltas,dc=com",
      "ldap\_kadmind\_dn": "cn=krbadmin,ou=users,dc=adaltas,dc=com",
      "ldap_servers": [
        "ldaps://master3.hadoop",
      ],
      "principals": [
        "principal": "wdavidw@ADALTAS.COM",
        "password": "test"
      ]
    }
  }
}
```

    safe_etc_krb5_conf = module.exports.safe_etc_krb5_conf = (etc_krb5_conf) ->
      etc_krb5_conf = misc.merge {}, etc_krb5_conf
      for realm, config of etc_krb5_conf.realms
        delete config.kadmin_principal
        delete config.kadmin_password
        delete config.principals
      for name, config of etc_krb5_conf.dbmodules
        delete config.kdc_master_key
        delete config.manager_dn
        delete config.manager_password
      etc_krb5_conf

    module.exports.etc_krb5_conf =
      'logging':
        'default': 'SYSLOG:INFO:LOCAL1'
        'kdc': 'SYSLOG:NOTICE:LOCAL1'
        'admin_server': 'SYSLOG:WARNING:LOCAL1'
      'libdefaults': 
        # 'default_realm': "#{REALM}"
        'dns_lookup_realm': false
        'dns_lookup_kdc': false
        'ticket_lifetime': '24h'
        'renew_lifetime': '7d'
        'forwardable': true
      'realms': {}
      'domain_realm': {}
      'appdefaults':
        'pam':
          'debug': false
          'ticket_lifetime': 36000
          'renew_lifetime': 36000
          'forwardable': true
          'krb4_convert': false
      'dbmodules': {}

    module.exports.push module.exports.configure = (ctx) ->
      ctx.config.krb5 ?= {}
      etc_krb5_conf = misc.merge {}, module.exports.etc_krb5_conf, ctx.config.krb5.etc_krb5_conf
      ctx.config.krb5.etc_krb5_conf = etc_krb5_conf
      kdc_conf = ctx.config.krb5.kdc_conf ?= {}
      # Generate dynamic "krb5.dbmodules" object
      openldap_hosts = ctx.hosts_with_module 'phyla/core/openldap_server_krb5'
      throw new Error "Expect at least one server with action \"phyla/core/openldap_server_krb5\"" if openldap_hosts.length is 0
      for host in openldap_hosts
        # ldap_manager_dn, ldap_manager_password, 
        {kerberos_container_dn, users_container_dn, manager_dn, manager_password} = ctx.hosts[host].config.openldap_krb5
        name = "openldap_#{host.split('.')[0]}"
        scheme = if ctx.hosts[host].has_module 'phyla/core/openldap_server_tls' then "ldap://" else "ldaps://"
        ldap_server =  "#{scheme}#{host}"
        etc_krb5_conf.dbmodules[name] = misc.merge 
          'db_library': 'kldap'
          'ldap_kerberos_container_dn': kerberos_container_dn
          'ldap_kdc_dn': users_container_dn
           # this object needs to have read rights on
           # the realm container, principal container and realm sub-trees
          'ldap_kadmind_dn': users_container_dn
           # this object needs to have read and write rights on
           # the realm container, principal container and realm sub-trees
          'ldap_service_password_file': "/etc/krb5.d/#{name}.stash.keyfile"
          # 'ldap_servers': 'ldapi:///'
          'ldap_servers': ldap_server
          'ldap_conns_per_server': 5
          'manager_dn': manager_dn
          'manager_password': manager_password
        , etc_krb5_conf.dbmodules[name]
      # Merge global with server-based configuration
      krb5_server_hosts = ctx.hosts_with_module "phyla/core/krb5_server"
      for krb5_server_host in krb5_server_hosts
        {realms} = misc.merge {}, ctx.hosts[krb5_server_host].config.krb5.etc_krb5_conf
        for realm, config of realms
          delete config.database_module
          realms[realm].kdc ?= krb5_server_host
          realms[realm].admin_server ?= krb5_server_host
          realms[realm].default_domain ?= realm.toLowerCase()
        misc.merge etc_krb5_conf.realms, realms
      for realm, config of etc_krb5_conf.realms
        # Check if realm point to a database_module
        if config.database_module
          # Make sure this db module is registered
          dbmodules = Object.keys(etc_krb5_conf.dbmodules).join ','
          valid = etc_krb5_conf.dbmodules[config.database_module]?
          throw new Error "Property database_module \"#{config.database_module}\" not in list: \"#{dbmodules}\"" unless valid
        # Set a database module if we manage the realm locally
        if config.admin_server is ctx.config.host
          # Valid if
          # *   only one OpenLDAP server accross the cluster or
          # *   an OpenLDAP server in this host
          openldap_index = openldap_hosts.indexOf ctx.config.host
          openldap_host = if openldap_hosts.length is 1 then openldap_hosts[0] else if openldap_index isnt -1 then openldap_index
          throw new Error "Could not find a suitable OpenLDAP server" unless openldap_host
          config.database_module = "openldap_#{openldap_host.split('.')[0]}"
      # Now that we have db_modules and realms, filter and validate the used db_modules
      database_modules = for realm, config of etc_krb5_conf.realms
        config.database_module
      for name, config of etc_krb5_conf.dbmodules
        # Filter
        if database_modules.indexOf(name) is -1
          delete etc_krb5_conf.dbmodules[name]
          continue
        # Validate
        throw new Error "Kerberos property `krb5.dbmodules.#{name}.kdc_master_key` is required" unless config.kdc_master_key
        throw new Error "Kerberos property `krb5.dbmodules.#{name}.ldap_kerberos_container_dn` is required" unless config.ldap_kerberos_container_dn
        throw new Error "Kerberos property `krb5.dbmodules.#{name}.ldap_kdc_dn` is required" unless config.ldap_kdc_dn
        throw new Error "Kerberos property `krb5.dbmodules.#{name}.ldap_kadmind_dn` is required" unless config.ldap_kadmind_dn
      # Generate the "domain_realm" property
      for realm of etc_krb5_conf.realms
        etc_krb5_conf.domain_realm[".#{realm.toLowerCase()}"] = realm
        etc_krb5_conf.domain_realm["#{realm.toLowerCase()}"] = realm
      # Prepare configuration for "kdc.conf"
      misc.merge kdc_conf,
        'kdcdefaults':
          'kdc_ports': 88
          'kdc_tcp_ports': 88
        'realms': {}
        'logging':
            'kdc': 'FILE:/var/log/kdc.log'
      , kdc_conf
      # Add realm present in etc_krb5_conf
      for realm of etc_krb5_conf.realms
        kdc_conf.realms[realm] = {}
      # Set default values each realm
      for realm, config of kdc_conf.realms
        kdc_conf.realms[realm] = misc.merge
          '#master_key_type': 'aes256-cts'
          'default_principal_flags': '+preauth'
          'acl_file': '/var/kerberos/krb5kdc/kadm5.acl'
          'dict_file': '/usr/share/dict/words'
          'admin_keytab': '/var/kerberos/krb5kdc/kadm5.keytab'
          'supported_enctypes': 'aes256-cts:normal aes128-cts:normal des3-hmac-sha1:normal arcfour-hmac:normal des-hmac-sha1:normal des-cbc-md5:normal des-cbc-crc:normal'
        , config
      # console.log etc_krb5_conf
      # console.log ''
      # console.log ''
      # console.log ''
      # console.log ''

    module.exports.push name: 'Krb5 Server # LDAP Install', timeout: -1, callback: (ctx, next) ->
      ctx.service
        name: 'krb5-server-ldap'
      , (err, installed) ->
        next err, if installed then ctx.OK else ctx.PASS

    module.exports.push name: 'Krb5 Server # LDAP Insert Entries', timeout: 100000, callback: (ctx, next) ->
      {etc_krb5_conf, kdc_conf} = ctx.config.krb5
      modified = false
      do_ini = ->
        ctx.log 'Update /etc/krb5.conf'
        ctx.ini
          content: safe_etc_krb5_conf etc_krb5_conf
          destination: '/etc/krb5.conf'
          stringify: misc.ini.stringify_square_then_curly
          backup: true
        , (err, written) ->
          return next err if err
          modified = true if written
          do_subtrees()
      do_subtrees = ->
        each(etc_krb5_conf.realms)
        .on 'item', (realm, config, next) ->
          return next() unless config.database_module
          {kdc_master_key, ldap_kerberos_container_dn, manager_dn, manager_password} = etc_krb5_conf.dbmodules[config.database_module]
          # Note, kdb5_ldap_util is using /etc/krb5.conf (server version)
          ctx.log 'Run kdb5_ldap_util'
          ctx.execute
            cmd: "kdb5_ldap_util -D \"#{manager_dn}\" -w #{manager_password} create -subtrees \"#{ldap_kerberos_container_dn}\" -r #{realm} -s -P #{kdc_master_key}"
            code_skipped: 1
          , (err, executed, stdout, stderr) ->
            # Warnig, exit code 1 for also for connect error
            # TODO: Test if the realm LDAP entry already exists
            return next err if err
            modified = true if executed
            next()
        .on 'both', (err) ->
          next err, if modified then ctx.OK else ctx.PASS
      do_ini()

    module.exports.push name: 'Krb5 Server # LDAP Stash password', callback: (ctx, next) ->
      {etc_krb5_conf} = ctx.config.krb5
      modified = false
      each(etc_krb5_conf.dbmodules)
      .on 'item', (name, dbmodule, next) ->
        {kdc_master_key, manager_dn, manager_password, ldap_service_password_file, ldap_kadmind_dn} = dbmodule
        ctx.log "Stash key file is: #{dbmodule.ldap_service_password_file}"
        keyfileContent = null
        do_read = ->
          ctx.log 'Read current keyfile if it exists'
          misc.file.readFile ctx.ssh, "#{ldap_service_password_file}", 'utf8', (err, content) ->
            return do_mkdir() if err and err.code is 'ENOENT'
            return next err if err
            keyfileContent = content
            do_stash()
        do_mkdir = ->
          ctx.log 'Create directory "/etc/krb5.d"'
          ctx.mkdir '/etc/krb5.d', (err, created) ->
            return next err if err
            do_stash()
        do_stash = ->
          ctx.log 'Stash password into local file'
          ctx.ssh.shell (err, stream) ->
            return next err if err
            cmd = "kdb5_ldap_util -D \"#{manager_dn}\" -w #{manager_password} stashsrvpw -f #{ldap_service_password_file} #{ldap_kadmind_dn}"
            ctx.log "Run #{cmd}"
            reentered = false
            stream.write "#{cmd}\n"
            stream.on 'data', (data, stderr) ->
              ctx.log[if stderr then 'err' else 'out'].write data
              data = data.toString()
              if /Password for/.test data
                stream.write "#{kdc_master_key}\n"
              else if /Re-enter password for/.test data
                stream.write "#{kdc_master_key}\n\n"
                reentered = true
              else if reentered
                stream.end()
            stream.on 'close', ->
              do_compare()
        do_compare = ->
          unless keyfileContent
            modified = true
            return next()
          misc.file.readFile ctx.ssh, "#{ldap_service_password_file}", 'utf8', (err, content) ->
            return next err if err
            modified = if keyfileContent is content then false else true
            next()
        do_read()
      .on 'both', (err) ->
        next err, if modified then ctx.OK else ctx.PASS

    module.exports.push name: 'Krb5 Server # Install', timeout: -1, callback: (ctx, next) ->
      ctx.log 'Install krb5kdc and kadmin services'
      ctx.service [
        name: 'krb5-pkinit-openssl'
      ,
        name: 'krb5-server-ldap'
        startup: true
        chk_name: 'krb5kdc'
        srv_name: 'krb5kdc'
      ,
        name: 'krb5-server-ldap'
        startup: true
        chk_name: 'kadmin'
        srv_name: 'kadmin'
      ,
        name: 'words'
      ,
        name: 'krb5-workstation'
      ], (err, serviced) ->
        next err, if serviced then ctx.OK else ctx.PASS

    module.exports.push name: 'Krb5 Server # Configure', timeout: 100000, callback: (ctx, next) ->
      {realm, etc_krb5_conf, kdc_conf} = ctx.config.krb5
      modified = false
      exists = false
      chkexists = ->
        misc.file.exists ctx.ssh, '/etc/krb5.conf', (err, e) ->
          exists = e
      do_krb5 = ->
        ctx.log 'Update /etc/krb5.conf'
        # Clone etc_krb5_conf
        etc_krb5_conf = misc.merge {}, etc_krb5_conf
        ctx.ini
          content: safe_etc_krb5_conf etc_krb5_conf
          destination: '/etc/krb5.conf'
          stringify: misc.ini.stringify_square_then_curly
          backup: true
        , (err, written) ->
          return next err if err
          modified = true if written
          do_kadm5()
      do_kadm5 = ->
        ctx.log 'Update /var/kerberos/krb5kdc/kadm5.acl'
        writes = for realm of etc_krb5_conf.realms
          match: ///^\*/\w+@#{misc.regexp.escape realm}\s+\*///mg
          replace: "*/admin@#{realm}     *"
          append: true
        ctx.write 
          write: writes
          destination: '/var/kerberos/krb5kdc/kadm5.acl'
          backup: true
        , (err, written) ->
          return next err if err
          modified = true if written
          do_kdc()
      do_kdc = ->
        ctx.log 'Update /var/kerberos/krb5kdc/kdc.conf'
        ctx.ini
          content: kdc_conf
          destination: '/var/kerberos/krb5kdc/kdc.conf'
          stringify: misc.ini.stringify_square_then_curly
          backup: true
        , (err, written) ->
          return next err if err
          modified = true if written
          do_end()
      do_end = (err) ->
        return next err if err
        return next null, ctx.PASS unless modified
        # The first time, we dont restart because ldap conf is 
        # not there yet
        return next null, ctx.OK unless exists
        ctx.log '(Re)start krb5kdc and kadmin services'
        ctx.service [
          name: 'krb5-server'
          action: 'restart'
          srv_name: 'krb5kdc'
        ,
          name: 'krb5-server'
          action: 'restart'
          srv_name: 'kadmin'
        ], (err, serviced) ->
          next err, ctx.OK
      do_krb5()

    module.exports.push name: 'Krb5 Server # Log', timeout: 100000, callback: (ctx, next) ->
      modified = false
      touch = ->
        ctx.log 'Touch "/etc/logrotate.d/krb5kdc" and "/etc/logrotate.d/kadmind"'
        ctx.write [
          content: ''
          destination: '/var/log/krb5kdc.log'
          not_if_exists: true
        ,
          content: ''
          destination: '/var/log/kadmind.log'
          not_if_exists: true
        ], (err, written) ->
          return done err if err
          modified = true if written
          rsyslog()
      rsyslog = ->
        ctx.log 'Update /etc/rsyslog.conf'
        ctx.write
          destination: '/etc/rsyslog.conf'
          write: [
            match: /.*krb5kdc.*/mg
            replace: 'if $programname == \'krb5kdc\' then /var/log/krb5kdc.log'
            append: '### RULES ###'
          ,
            match: /.*kadmind.*/mg
            replace: 'if $programname == \'kadmind\' then /var/log/kadmind.log'
            append: '### RULES ###'
          ]
        , (err, written) ->
          return done err if err
          modified = true if written
          if written then restart() else done()
      restart = ->
        ctx.log 'Restart krb5kdc and kadmin'
        ctx.service [
          name: 'krb5-server'
          action: 'start'
          srv_name: 'krb5kdc'
        ,
          name: 'krb5-server'
          action: 'start'
          srv_name: 'kadmin'
        ], (err, restarted) ->
          return done err if err
          ctx.log 'Restart rsyslog'
          ctx.service
            name: 'rsyslog'
            action: 'restart'
          , (err, restarted) ->
            done err
      done = (err) ->
        next err, if modified then ctx.OK else ctx.PASS
      touch()

    module.exports.push name: 'Krb5 Server # Admin principal', timeout: -1, callback: (ctx, next) ->
      {etc_krb5_conf} = ctx.config.krb5
      modified = false
      each(etc_krb5_conf.realms)
      .on 'item', (realm, config, next) ->
        {database_module, kadmin_principal, kadmin_password} = config
        return next() unless database_module
        ctx.log "Create principal #{kadmin_principal}"
        ctx.krb5_addprinc
          # We dont provide an "kadmin_server". Instead, we need
          # to use "kadmin.local" because the principal used
          # to login with "kadmin" isnt created yet
          principal: kadmin_principal
          password: kadmin_password
        , (err, created) ->
          return next err if err
          modified = true if created
          next()
      .on 'both', (err) ->
        next err, if modified then ctx.OK else ctx.PASS

    module.exports.push name: 'Krb5 Server # Start', timeout: 100000, callback: (ctx, next) ->
      ctx.service [
        name: 'krb5-server-ldap'
        action: 'start'
        srv_name: 'krb5kdc'
      ,
        name: 'krb5-server-ldap'
        action: 'start'
        srv_name: 'kadmin'
      ], (err, serviced) ->
        next err, if serviced then ctx.OK else ctx.PASS

## Krb5 Client

Call the "phyla/core/krb5_client" dependency which will register this host to
each Kerberos servers.

    module.exports.push '!phyla/core/krb5_client'

# ## Populate

# Populate DB with machines and users principals.

#     module.exports.push name: 'Krb5 Server # Populate', timeout: -1, callback: (ctx, next) ->
#       {realm, principals, kadmin_principal, kadmin_password, kadmin_server} = ctx.config.krb5
#       modified = false
#       do_wait = ->
#         # It takes time after Kerberos is started and before `kadmin` is really ready
#         ctx.waitForExecution "kadmin -p #{kadmin_principal} -w #{kadmin_password} -s #{kadmin_server} -q ?", (err) ->
#           return next err if err
#           do_createMachinePrincipal()
#       do_createMachinePrincipal = ->
#         ctx.log "Create principal host/#{ctx.config.host}@#{realm}"
#         ctx.krb5_addprinc
#           principal: "host/#{ctx.config.host}@#{realm}"
#           randkey: true
#           kadmin_principal: kadmin_principal
#           kadmin_password: kadmin_password
#           kadmin_server: kadmin_server
#         , (err, created) ->
#           return next err if err
#           modified = true if created
#           do_createConfigPrincipals()
#       do_createConfigPrincipals = ->
#         each(principals)
#         .on 'item', (principal, next) ->
#           ctx.log "Create principal {principal}"
#           options = 
#             kadmin_principal: kadmin_principal
#             kadmin_password: kadmin_password
#             kadmin_server: kadmin_server
#           for k, v of principal then options[k] = v
#           ctx.krb5_addprinc options, (err, created) ->
#             return next err if err
#             modified = true if created
#             next()
#         .on 'both', (err) ->
#           do_end err
#       do_end = (err) ->
#         next err, if modified then ctx.OK else ctx.PASS
#       do_wait()



## Notes

Renewable tickets is per default disallowed in the most linux distributions. This can be done per:

```bash
kadmin.local: modprinc -maxrenewlife 7day krbtgt/YOUR_REALM
kadmin.local: modprinc -maxrenewlife 7day +allow_renewable hue/FQRN
```





