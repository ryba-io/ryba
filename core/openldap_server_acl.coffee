
module.exports = []
module.exports.push 'phyla/bootstrap'
module.exports.push 'phyla/core/openldap_server'

###
OpenLDAP ACL
============
###

module.exports.push (ctx, next) ->
  require('./openldap_connection').configure ctx, next

###
After this call, the follwing command should succeed:

    ldapsearch -H ldap://master3.hadoop:389 -D cn=nssproxy,ou=users,dc=adaltas,dc=com -w test
###
module.exports.push name: 'OpenLDAP ACL # Permissions for nssproxy', callback: (ctx, next) ->
  {suffix} = ctx.config.openldap_server
  ctx.ldap_acl
    ldap: ctx.ldap_config
    name: 'olcDatabase={2}bdb,cn=config'
    acls: [
      to: 'attrs=userPassword,userPKCS12'
      by: [
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
        "dn.exact=\"cn=nssproxy,ou=users,#{suffix}\" read"
        'self write'
        'anonymous auth'
        '* none'
      ]
    ,
      to: 'attrs=shadowLastChange'
      by: [
        'self write'
        'dn.base="gidNumber=0+uidNumber=0,cn=peercred,cn=external,cn=auth" manage'
        "dn.exact=\"cn=nssproxy,ou=users,#{suffix}\" read"
        '* none'
      ]
    ,
      to: "dn.subtree=\"#{suffix}\""
      by: [
        "dn.exact=\"cn=nssproxy,ou=users,#{suffix}\" read"
        '* none'
      ]
    ]
  , (err, modified) ->
    next err, if modified then ctx.OK else ctx.PASS

module.exports.push name: 'OpenLDAP ACL # Insert User', callback: (ctx, next) ->
  ctx.ldap_add ctx, """
  dn: cn=nssproxy,ou=users,dc=adaltas,dc=com
  uid: nssproxy
  gecos: Network Service Switch Proxy User
  objectClass: top
  objectClass: account
  objectClass: posixAccount
  objectClass: shadowAccount
  userPassword: {SSHA}uQcSsw5CySTkBXjOY/N0hcduA6yFiI0k
  shadowLastChange: 15140
  shadowMin: 0
  shadowMax: 99999
  shadowWarning: 7
  loginShell: /bin/false
  uidNumber: 801
  gidNumber: 801
  homeDirectory: /home/nssproxy

  dn: cn=test,ou=users,dc=adaltas,dc=com
  uid: test
  gecos: Test User
  objectClass: top
  objectClass: account
  objectClass: posixAccount
  objectClass: shadowAccount
  #userPassword: {SSHA}uQcSsw5CySTkBXjOY/N0hcduA6yFiI0k
  shadowLastChange: 15140
  shadowMin: 0
  shadowMax: 99999
  shadowWarning: 7
  loginShell: /bin/bash
  uidNumber: 1101
  gidNumber: 1101
  homeDirectory: /home/test

  dn: cn=nssproxy,ou=groups,dc=adaltas,dc=com
  cn: nssproxy
  objectClass: top
  objectClass: posixGroup
  gidNumber: 801
  description: Network Service Switch Proxy
  """, (err, added) ->
    next err, if added then ctx.OK else ctx.PASS




