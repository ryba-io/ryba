# Ambari Server

[Ambari-server][Ambari-server] is the master host for ambari software.
Once logged into the ambari server host, the administrator can  provision, 
manage and monitor a Hadoop cluster.

## Configuration

### General Options

* `db_hive.database` (string)   
  Name of the database storing the Hive database.
* `db_hive.enabled` (boolean)   
  Prepare the Hive database.
* `db_hive.engine` (boolean)   
  Type of database; one of "mariadb", "mysql" or "postgresql".
* `db_hive.password` (boolean)   
  Password associated with the database administrator user.
* `db_hive.username` (boolean)   
  Hive database administrator user.

### LDAP options

* `ldap.ldap-url` (string)   
  Primary URL for LDAP (must not be used together with `ldap-primary-host` and 
  `ldap-primary-port`)
* `ldap.ldap-primary-host` (string)   
  Primary Host for LDAP (must not be used together with --ldap-url)
* `ldap.ldap-primary-port` (string|number)   
  Primary Port for LDAP (must not be used together with --ldap-url)
* `ldap.ldap-secondary-url` (string)   
  Secondary URL for LDAP (must not be used together with --ldap-secondary-host and --ldap-secondary-port)
* `ldap.ldap-secondary-host` (string)   
  Secondary Host for LDAP (must not be used together with --ldap-secondary-url)
* `ldap.ldap-secondary-port` (string|number)   
  Secondary Port for LDAP (must not be used together with --ldap-secondary-url)
* `ldap.ldap-ssl` (boolean|string)   
  Use SSL [true/false] for LDAP
* `ldap.ldap-type` (string)   
  Specify ldap type [AD/IPA/Generic] for offering defaults for missing options.
* `ldap.ldap-user-class` (string)   
  User Attribute Object Class for LDAP
* `ldap.ldap-user-attr` (string)   
  User Attribute Name for LDAP
* `ldap.ldap-group-class` (string)   
  Group Attribute Object Class for LDAP
* `ldap.ldap-group-attr` (string)   
  Group Attribute Name for LDAP
* `ldap.ldap-member-attr` (string)   
  Group Membership Attribute Name for LDAP
* `ldap.ldap-dn` (string)   
  Distinguished name attribute for LDAP
* `ldap.ldap-base-dn` (string)   
  Base DN for LDAP
* `ldap.ldap-manager-dn` (string)   
  Manager DN for LDAP
* `ldap.ldap-manager-password` (string)   
  Manager Password For LDAP
* `ldap.ldap-save-settings` (boolean|string)   
  Save without review for LDAP
* `ldap.ldap-referral` (string)   
  Referral method [follow/ignore] for LDAP
* `ldap.ldap-bind-anonym` (string)   
  Bind anonymously [true/false] for LDAP
* `ldap.ldap-sync-username-collisions-behavior` (string)   
  Handling behavior for username collisions [convert/skip] for LDAP sync
* `ldap.ldap-sync-disable-endpoint-identification` (string)   
  Determines whether to disable endpoint identification (hostname verification) during SSL handshake for LDAP sync. This option takes effect only if --ldap-ssl is set to 'true'
* `ldap.ldap-force-lowercase-usernames` (string)   
  Declares whether to force the ldap user name to be lowercase or leave as-is
* `ldap.ldap-pagination-enabled` (string)   
  Determines whether results from LDAP are paginated when requested
* `ldap.ldap-force-setup` (boolean|string)   
  Forces the use of LDAP even if other (i.e. PAM) authentication method is
  configured already or if there is no authentication method configured at all
* `ldap.ambari-admin-username` (string)  
  Ambari administrator username for accessing Ambari's REST API
* `ldap.ambari-admin-password` (string)  
  Ambari administrator password for accessing Ambari's REST API
* `ldap.truststore-type` (string)  
  Type of TrustStore (jks|jceks|pkcs12)
* `ldap.truststore-path` (string)  
  Path of TrustStore
* `ldap.truststore-password` (string)  
  Password for TrustStore
* `ldap.truststore-reconfigure` (string)  
  Force to reconfigure TrustStore if exits

### Minimal Example

```yaml
config:
  admin_password: MySecret
  db:
    password: MySecret
```

### Database Encryption

```yaml
config:
  master_key: MySecret
```

### Enable sudoer

```yaml
config:
  ambari-server.user: ambari
```

### LDAP Connection

```yaml
config:
  client.security: ldap
  authentication.ldap.useSSL: true,
  authentication.ldap.primaryUrl: master3.ryba:636
  authentication.ldap.baseDn: ou=users,dc=ryba
  authentication.ldap.bindAnonymously: false,
  authentication.ldap.managerDn: cn=admin,ou=users,dc=ryba
  authentication.ldap.managerPassword: XXX
  authentication.ldap.usernameAttribute: cn
```

## IPTables

| Service       | Port  | Proto | Parameter       |
|---------------|-------|-------|-----------------|
| Ambari Server | 8080  |  tcp  |  HTTP Port      |
| Ambari Server | 8842  |  tcp  |  HTTPS Port     |

IPTables rules are only inserted if the parameter "iptables.action" is set to
"start" (default value).

## Resouces

- [Ambari-server](http://ambari.apache.org)
