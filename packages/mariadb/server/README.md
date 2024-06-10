
# MariaDB Server

- `sql_on_install` (array|string)
- `current_password` (string)
- `password` (string)
- `remove_anonymous` (boolean)
- `disallow_remote_root_login` (boolean)
- `remove_test_db` (boolean)
- `reload_privileges` (boolean)
- `my_cnf` (object)
  Object to be serialized into the "ini" format inside "/etc/my.cnf"

## Default configuration:

```
{ "mysql": {
  "server": {
    "sql_on_install": [],
    "current_password": "",
    "password": "",
    "remove_anonymous": true,
    "disallow_remote_root_login": false,
    "remove_test_db": true,
    "reload_privileges": true,
    "my_cnf": {
      "mysqld": {
        "tmpdir": "/tmp/mysql"
      }
    }
  }
}
```

## Copying an existing certificate on the target node

```
{ "tls": {
    "enabled": true,
    "cacert": { source: "/etc/ipa/ca.pem" },
    "cert": { source: "/etc/ipa/cert.pem" },
    "key": { source: "/etc/ipa/key.pem" }
} }
```

## IPTables

| Service         | Port | Proto | Parameter |
|-----------------|------|-------|-----------|
| MariaDB         | 3306 | tcp   | -         |


IPTables rules are only inserted if the parameter "iptables.action" is set to
"start" (default value).

## User & groups

By default the "mariadb-server" package creates the following entry:

```bash
cat /etc/passwd | grep mysql
mysql:x:27:27:MariaDB Server:/var/lib/mysql:/sbin/nologin
```
Actions present to be able to change uid/gid:
Note: Be careful if using different name thans 'mysql:mysql'
User/group are hard coded in some of mariadb/mysql package scripts.

# Server Replication

It follow [instructions from here](https://www.digitalocean.com/community/tutorials/how-to-set-up-master-slave-replication-in-mysql).

Note: Ryba does not do any action if replication has already be enabled once for
consistency reasons.
