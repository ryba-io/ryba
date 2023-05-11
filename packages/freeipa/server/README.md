
# FreeIPA server

Integrated security information management solution combining Linux (Fedora), 389 Directory Server, MIT Kerberos, NTP, DNS, Dogtag certificate system, SSSD and others.

Main characteristics:
- Built on top of well known Open Source components and standard protocols
- Strong focus on ease of management and automation of installation and configuration tasks.
- Full multi master replication for higher redundancy and scalability
- Extensible management interfaces (CLI, Web UI, XMLRPC and JSONRPC API) and Python SDK

## Implementation

The package follows the [quick start guide](https://www.freeipa.org/page/Quick_Start_Guide) and [production deployment configuration](https://www.freeipa.org/page/Deployment_Recommendations).

## Configuration

* `admin_password` (string, required)   
  The password for the IPA admin user.
* `domain` (string, required)   
  Primary DNS domain of the IPA deployment (not necessarily related to the 
  current hostname); same as FreeIPA "-n" option.
* `dns_auto_forward` (boolean, optional, false)   
  Use DNS forwarders configured in /etc/resolv.conf ("--auto-forwarders"); can
  be combined with `dns_forwarder`.
* `dns_forwarder` (string|array|boolean, optional, [])   
  Set one or multiple DNS; can be combined with `auto_forwarder`.
  /etc/resolv.conf ("--auto-forwarders"); if string or array, add one or 
  multiple DNS forwarder.
* `idstart` (number, optional, undefined)
  The starting value for the IDs range (FreeIPA default: random).
* `idmax` (number, optional, undefined)
  The max value for the IDs range (FreeIPA default: idstart+199999).
* `manager_password` (string, required)   
  The password to be used by the Directory Server for the Directory Manager user.

## Schema

```js
{
  schema: {
    type: 'object',
    properties: {
      'admin_password': {
        type: 'string',
        description: 'Administrator password',
      },
      'apache': {
        type: 'object'
        description: 'Information relative to the apache user.',
        properties:
          group: '$ref': 'registry://system/group'
          user: '$ref': 'registry://system/user'
      },
      'ca_subject': {
        type: '',
        description: dedent`
        The certificate authority (CA) subject, it corresponds to the
        "--ca-subject" IPA argument and it is only used if 'external_ca' is
        \`true\`. An exemple is \`"CN=Certificate Authority,O=AU.ADALTAS.CLOUD"\`.
        `,
      },
      'conf_dir': {
        type: 'string',
        description: '',
      },
      'dirsrv': {
        type: 'object',
        description: 'Information relative to the dirsrv user.',
        properties: {
          group: '$ref': 'registry://system/group',
          user: '$ref': 'registry://system/user',
        },
      },
      'dns_auto_forward': {
        type: '',
        description: '',
      },
      'dns_auto_reverse': {
        type: '',
        description: '',
      },
      'dns_enabled': {
        type: 'boolean',
        description: '',
      },
      'dns_forwarder': {
        type: 'array'
        description: dedent`
        The DNS forwarder used to forward external DNS requests. It
        corresponds to the "--forwarder" IPA argument. An example is
        \`[['1.1.1.1', '1.0.0.1']]\`.
        `
        items: {
          type: 'string',
          format: 'ipv4',
        },
      },
      'domain': {
        type: '',
        description: '',
      },
      'external_ca': {
        type: 'boolean',
        description: 'Indicate the usage of an external certificate authority (CA).',
      },
      'fqdn': {
        type: '',
        description: 'The server FQDN. It corresponds to the "--hostname" IPA argument.',
      },
      'hsqldb': {
        type: 'object',
        description: 'Information relative to the hsqldb user.',
        properties: {
          group: '$ref': 'registry://system/group',
          user: '$ref': 'registry://system/user',
        },
      },
      'idmax': {
        type: '',
        description: '',
      },
      'idstart': {
        type: '',
        description: '',
      },
      'ip_address': {
        type: '',
        description: '',
      },
      'iptables': {
        type: '',
        description: '',
      },
      'manage_users_groups': {
        type: '',
        description: '',
      },
      'manager_password': {
        type: '',
        description: '',
      },
      'memcached': {
        type: 'object',
        description: 'Information relative to the memcached user.',
        properties: {
          group: '$ref': 'registry://system/group',
          user: '$ref': 'registry://system/user',
        },
      },
      'no_krb5_offline_passwords': {
        type: '',
        description: '',
      },
      'ntp': {
        type: 'boolean',
        description: '',
      },
      'ntp_enabled': {
        type: '',
        description: '',
      },
      'ods': {
        type: 'object',
        description: 'Information relative to the ods user.',
        properties: {
          group: '$ref': 'registry://system/group',
          user: '$ref': 'registry://system/user',
        },
      },
      'pkiuser': {
        type: 'object',
        description: 'Information relative to the pkiuser user.',
        properties: {
          group: '$ref': 'registry://system/group',
          user: '$ref': 'registry://system/user',
        },
      },
      'realm_name': {
        type: '',
        description: '',
      },
      'ssl_ca_cert_local': {
        type: '',
        description: '',
      },
      'ssl_cert_file': {
        type: '',
        description: '',
      },
      'ssl_enabled': {
        type: '',
        description: '',
      },
      'ssl_key_local': {
        type: '',
        description: '',
      },
      'ssl_key_file': {
        type: '',
        description: '',
      },
      'tomcat': {
        type: 'object',
        description: 'Information relative to the tomcat user.',
        properties: {
          group: '$ref': 'registry://system/group',
          user: '$ref': 'registry://system/user',
        },
      },
    }
  }
}
```

## Example

```js
{
  "options": {
    // Kerberos
    "manager_password": "DM_PASSWORD",
    "admin_password": "ADMIN_PASSWORD",
    "realm_name": "MASSON",
    "ntp_enabled": true,
    "domain": "", // Required
    // DNS
    "dns_enabled": true,
    "dns_email_manager": "", // Required
    "dns_auto_reverse": true,
    "dns_auto_forward": false,
    "dns_forwarder": ['1.1.1.1', '1.0.0.1'],
    // SSL/TLS
    "ssl_enabled": true,
    "ssl_cert_file": "", // Required
    "ssl_key_file": "" // Required
  }
}
```

## IPTables

| Service    | Port | Proto | Parameter                            |
|------------|------|-------|--------------------------------------|
| kadmin     | 749  | tcp   | `kdc_conf.kdcdefaults.kadmind_port`  |
| krb5kdc    | 88   | upd   | `kdc_conf.kdcdefaults.kdc_ports`     |
| krb5kdc    | 88   | tcp   | `kdc_conf.kdcdefaults.kdc_tcp_ports` |

IPTables rules are only inserted if the parameter "iptables.action" is set to
"start" (default value).

## Commands

Lifecycle

```bash
ipactl --help
Usage: ipactl start|stop|restart|status
```

Debugging

```bash
ipactl status
journalctl -u dirsrv@{domain}.service -f
```

## Directory

Kerberos logs "krb5kdc" can grow large. [Configuring logrotate](http://www.rjsystems.nl/en/2100-kerberos-master.php) seems like an appropriate option. Also, checkout the tomcat-pki logs.

```bash
rm -rf /var/log/krb5kdc.log*
rm -rf /var/log/pki/pki-tomcat/*.log
rm -rf /var/log/pki/pki-tomcat/*.txt
```

## Logs files

* /var/log/httpd/access_log
* /var/log/httpd/access_log-{YYYYMMDD}
* `/var/log/httpd/error_log`   
  `/var/log/httpd/error_log-{YYYYMMDD}`   
  FreeIPA API call logs (and Apache errors)

* /var/log/ipa/ipactl.log
* /var/log/ipa/renew.log
* /var/log/ipa/restart.log

* /var/log/ipa-custodia.audit.log
* /var/log/ipaclient-install.log
* /var/log/ipaserver-install.log

* `/var/log/kadmind.log`   
  `/var/log/kadmind.log-{YYYYMMDD}`   
* `/var/log/krb5kdc.log`
  `/var/log/krb5kdc.log-{YYYYMMDD}`   
  FreeIPA KDC utilization

* `/var/log/dirsrv/slapd-$REALM/access`   
  Directory Server utilization
* `/var/log/dirsrv/slapd-$REALM/errors`   
  Directory Server errors (including mentioned replication errors)
* `/var/log/pki/pki-tomcat/catalina.{YYYY-MM-DD}.log`
  `/var/log/pki/pki-tomcat/host-manager.{YYYY-MM-DD}.log`
  `/var/log/pki/pki-tomcat/localhost.{YYYY-MM-DD}.log`
  `/var/log/pki/pki-tomcat/localhost_access_log.{YYYY-MM-DD}.log`
  `/var/log/pki/pki-tomcat/manager.{YYYY-MM-DD}.log`
  FreeIPA PKI logs
* `/var/log/pki/pki-tomcat/ca/transactions`   
  FreeIPA PKI transactions logs

Client logs:

* `/var/log/sssd/*.log`   
  SSSD logs (multiple, for all tracked logs)
* `/var/log/audit/audit.log`   
  User login attempts
* `/var/log/secure`   
  Reasons why user login failed

## About renewable tickets

Renewable tickets is per default disallowed in most linux distributions. This can be done with:

```bash
kadmin.local: modprinc -maxrenewlife 7day krbtgt/YOUR_REALM
kadmin.local: modprinc -maxrenewlife 7day +allow_renewable hue/FQRN
```
