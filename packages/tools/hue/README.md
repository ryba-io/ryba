
# Hue

[Hue](http://gethue.com) features a File Browser for HDFS, a Job Browser for MapReduce/YARN,
an HBase Browser, query editors for Hive, Pig, Cloudera Impala and Sqoop2.
It also ships with an Oozie Application for creating and monitoring workflows,
a Zookeeper Browser and a SDK.

Link to configure [hive hue configuration](http://www.cloudera.com/content/www/en-us/documentation/cdh/5-0-x/CDH5-Security-Guide/cdh5sg_hue_security.html) over ssl.

## Configuration

*   `hdp.hue.ini.desktop.database.admin_username` (string)
    Database admin username used to create the Hue database user.
*   `hdp.hue.ini.desktop.database.admin_password` (string)
    Database admin password used to create the Hue database user.
*   `hue.ini`
    Configuration merged with default values and written to "/etc/hue/conf/hue.ini" file.
*   `hue.user` (object|string)
    The Unix Hue login name or a user object (see Nikita User documentation).
*   `hue.group` (object|string)
    The Unix Hue group name or a group object (see Nikita Group documentation).

### Example

```json
{
  "ryba": {
    "hue": {
      "user": {
        "name": "hue", "system": true, "gid": "hue",
        "comment": "Hue User", "home": "/usr/lib/hue"
      },
      "group": {
        "name": "Hue", "system": true
      },
      "ini": {
        "desktop": {
          "database":
            "engine": "mysql"
            "password": "hue123"
          "custom": {
            "banner_top_html": "HADOOP : PROD"
          }
        }
      },
      "banner_style": "color:white;text-align:center;background-color:red;",
      "clean_tmp": false
    }
  }
}
```

## Identities

By default, the "hue" package create the following entries:

```bash
cat /etc/passwd | grep hue
hue:x:494:494:Hue:/var/lib/hue:/sbin/nologin
cat /etc/group | grep hue
hue:x:494:
```

## IPTables

| Service    | Port  | Proto | Parameter          |
|------------|-------|-------|--------------------|
| Hue Web UI | 8888  | http  | desktop.http_port  |

IPTables rules are only inserted if the parameter "iptables.action" is set to 
"start" (default value).

## Operations

Start the Hue server. You can also start the server manually with the following
command:

```
service hue start
```

Stop the Hue server. You can also stop the server manually with the following
command:

```
service hue stop
```

Check if the Hue server is running. The process ID is located by default
inside "/var/run/hue/supervisor.pid".


## Uninstallation

Here's how to uninstall Hue: `rpm -qa | grep hue | xargs sudo rpm -e`. This
article from december 2014 describe how to  [install the latest version of hue
on HDP](http://gethue.com/how-to-deploy-hue-on-hdp/).

## Resources

*   [Official Hue website](http://gethue.com)
*   [Hortonworks instructions](http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.8.0/bk_installing_manually_book/content/rpm-chap-hue.html)
