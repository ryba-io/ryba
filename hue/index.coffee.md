
# Hue

[Hue][home] features a File Browser for HDFS, a Job Browser for MapReduce/YARN,
an HBase Browser, query editors for Hive, Pig, Cloudera Impala and Sqoop2.
It also ships with an Oozie Application for creating and monitoring workflows,
a Zookeeper Browser and a SDK.

    module.exports = []

## Configure

*   `hdp.hue.ini.desktop.database.admin_username` (string)
    Database admin username used to create the Hue database user.
*   `hdp.hue.ini.desktop.database.admin_password` (string)
    Database admin password used to create the Hue database user.
*   `hue.ini`
    Configuration merged with default values and written to "/etc/hue/conf/hue.ini" file.
*   `hue.user` (object|string)
    The Unix Hue login name or a user object (see Mecano User documentation).
*   `hue.group` (object|string)
    The Unix Hue group name or a group object (see Mecano Group documentation).

Example:

```json
{
  "ryba": {
    "hue: {
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
            banner_top_html: "HADOOP : PROD"
          }
        }
      },
      banner_style: 'color:white;text-align:center;background-color:red;',
      clean_tmp: false
    }
  }
}
```

    module.exports.configure_system = (ctx) ->
      ctx.config.ryba ?= {}
      hue = ctx.config.ryba.hue ?= {}
      # Layout
      hue.conf_dir ?= '/etc/hue/conf'
      # User
      hue.user ?= {}
      hue.user = name: hue.user if typeof hue.user is 'string'
      hue.user.name ?= 'hue'
      hue.user.system ?= true
      hue.user.comment ?= 'Hue User'
      hue.user.home = '/var/lib/hue'
      # Group
      hue.group = name: hue.group if typeof hue.group is 'string'
      hue.group ?= {}
      hue.group.name ?= 'hue'
      hue.group.system ?= true
      hue.user.gid = hue.group.name
      hue.clean_tmp ?= true

    module.exports.configure = (ctx) ->
      require('masson/core/iptables').configure
      require('../hadoop/core').configure ctx
      require('../hadoop/hdfs_client').configure ctx
      require('../hadoop/yarn_client').configure ctx
      require('../hive/client').configure ctx
      module.exports.configure_system ctx
      {ryba} = ctx.config
      {hadoop_conf_dir, webhcat, hue, db_admin, core_site, hdfs, yarn} = ryba
      nn_ctxs = ctx.contexts 'ryba/hadoop/hdfs_nn'
      hue ?= {}
      hue.ini ?= {}
      # todo, this might not work as expected after ha migration
      nodemanagers = ctx.hosts_with_module 'ryba/hadoop/yarn_nm'
      # Webhdfs should be active on the NameNode, Secondary NameNode, and all the DataNodes
      # throw new Error 'WebHDFS not active' if ryba.hdfs.site['dfs.webhdfs.enabled'] isnt 'true'
      hue.ca_bundle ?= '/etc/hue/conf/trust.pem'
      hue.ssl ?= {}
      hue.ssl.client_ca ?= null
      throw Error "Property 'hue.ssl.client_ca' required in HA with HTTPS" if nn_ctxs.length > 1 and ryba.hdfs.site['dfs.http.policy'] is 'HTTPS_ONLY' and not hue.ssl.client_ca
      # HDFS & YARN url
      # NOTE: default to unencrypted HTTP
      # error is "SSL routines:SSL3_GET_SERVER_CERTIFICATE:certificate verify failed"
      # see https://github.com/cloudera/hue/blob/master/docs/manual.txt#L433-L439
      # another solution could be to set REQUESTS_CA_BUNDLE but this isnt tested
      # see http://www.cloudera.com/content/cloudera/en/documentation/core/latest/topics/cm_sg_ssl_hue.html

      # Hue Install defines a dependency on HDFS client
      nn_protocol = if ryba.hdfs.site['dfs.http.policy'] is 'HTTP_ONLY' then 'http' else 'https'
      nn_protocol = 'http' if ryba.hdfs.site['dfs.http.policy'] is 'HTTP_AND_HTTPS' and not hue.ssl_client_ca
      if ryba.hdfs.site['dfs.ha.automatic-failover.enabled'] is 'true'
        nn_host = ryba.active_nn_host
        shortname = ctx.contexts(hosts: nn_host)[0].config.shortname
        nn_http_port = ryba.hdfs.site["dfs.namenode.#{nn_protocol}-address.#{ryba.nameservice}.#{shortname}"].split(':')[1]
        webhdfs_url = "#{nn_protocol}://#{nn_host}:#{nn_http_port}/webhdfs/v1"
      else
        nn_host = nn_ctxs[0].config.host
        nn_http_port = hdfs.site["dfs.namenode.#{nn_protocol}-address"].split(':')[1]
        webhdfs_url = "#{nn_protocol}://#{nn_host}:#{nn_http_port}/webhdfs/v1"
      # Support for RM HA was added in Hue 3.7
      # rm_protocol = if yarn.site['yarn.http.policy'] is 'HTTP_ONLY' then 'http' else 'https'

      # rm_hosts = ctx.hosts_with_module 'ryba/hadoop/yarn_rm'
      # if rm_hosts.length > 1
      #   rm_host = ryba.yarn.active_rm_host
      #   rm_ctx = ctx.context rm_host, require('../hadoop/yarn_rm').configure
      #   rm_port = rm_ctx.config.ryba.yarn.site["yarn.resourcemanager.address.#{rm_ctx.config.shortname}"].split(':')[1]
      #   yarn_api_url = if yarn.site['yarn.http.policy'] is 'HTTP_ONLY'
      #   then "http://#{yarn.site['yarn.resourcemanager.webapp.address.#{rm_ctx.config.shortname}']}"
      #   else "https://#{yarn.site['yarn.resourcemanager.webapp.https.address.#{rm_ctx.config.shortname}']}"
      # else
      #   rm_host = rm_hosts[0]
      #   rm_ctx = ctx.context rm_host, require('../hadoop/yarn_rm').configure
      #   rm_port = rm_ctx.config.ryba.yarn.site['yarn.resourcemanager.address'].split(':')[1]
      #   yarn_api_url = if yarn.site['yarn.http.policy'] is 'HTTP_ONLY'
      #   then "http://#{yarn.site['yarn.resourcemanager.webapp.address']}"
      #   else "https://#{yarn.site['yarn.resourcemanager.webapp.https.address']}"
      # YARN ResourceManager
      rm_ctxs = ctx.contexts 'ryba/hadoop/yarn_rm', require('../hadoop/yarn_rm').configure
      throw Error "No YARN ResourceManager configured" unless rm_ctxs.length
      is_yarn_ha = rm_ctxs.length > 1
      rm_ctx = rm_ctxs[0]
      yarn_shortname = if is_yarn_ha then ".#{rm_ctx.config.shortname}" else ''
      rm_host = rm_ctx.config.host
      # Strange, "rm_rpc_url" default to "http://localhost:8050" which doesnt make
      # any sense since this isnt http
      rm_rpc_add = rm_ctx.config.ryba.yarn.site["yarn.resourcemanager.address#{yarn_shortname}"]
      rm_rpc_url = "http://#{rm_rpc_add}"
      rm_port = rm_rpc_add.split(':')[1]
      yarn_api_url = if rm_ctx.config.ryba.yarn.site['yarn.http.policy'] is 'HTTP_ONLY'
      then "http://#{yarn.site['yarn.resourcemanager.webapp.address']}"
      else "https://#{yarn.site['yarn.resourcemanager.webapp.https.address']}"
      # NodeManager
      [nm_ctx] = ctx.contexts 'ryba/hadoop/yarn_nm', require('../hadoop/yarn_nm').configure
      node_manager_api_url = if ctx.config.ryba.yarn.site['yarn.http.policy'] is 'HTTP_ONLY'
      then "http://#{nm_ctx.config.ryba.yarn.site['yarn.nodemanager.webapp.address']}"
      else "https://#{nm_ctx.config.ryba.yarn.site['yarn.nodemanager.webapp.https.address']}"
      # WebHcat
      [webhcat_ctx] = ctx.contexts 'ryba/hive/webhcat', require('../hive/webhcat').configure
      if webhcat_ctx
        webhcat_port = webhcat_ctx.config.ryba.webhcat.site['templeton.port']
        templeton_url = "http://#{webhcat_ctx.config.host}:#{webhcat_port}/templeton/v1/"
      # Configure HDFS Cluster
      hue.ini['hadoop'] ?= {}
      hue.ini['hadoop']['hdfs_clusters'] ?= {}
      hue.ini['hadoop']['hdfs_clusters']['default'] ?= {}
      # HA require webhdfs_url
      hue.ini['hadoop']['hdfs_clusters']['default']['fs_defaultfs'] ?= core_site['fs.defaultFS']
      hue.ini['hadoop']['hdfs_clusters']['default']['webhdfs_url'] ?= webhdfs_url
      hue.ini['hadoop']['hdfs_clusters']['default']['hadoop_hdfs_home'] ?= '/usr/lib/hadoop'
      hue.ini['hadoop']['hdfs_clusters']['default']['hadoop_bin'] ?= '/usr/bin/hadoop'
      hue.ini['hadoop']['hdfs_clusters']['default']['hadoop_conf_dir'] ?= hadoop_conf_dir
      # Configure YARN (MR2) Cluster
      hue.ini['hadoop']['yarn_clusters'] ?= {}
      hue.ini['hadoop']['yarn_clusters']['default'] ?= {}
      hue.ini['hadoop']['yarn_clusters']['default']['resourcemanager_host'] ?= "#{rm_host}" # Might no longer be required after hdp2.2
      hue.ini['hadoop']['yarn_clusters']['default']['resourcemanager_port'] ?= "#{rm_port}" # Might no longer be required after hdp2.2
      hue.ini['hadoop']['yarn_clusters']['default']['submit_to'] ?= "true"
      hue.ini['hadoop']['yarn_clusters']['default']['hadoop_mapred_home'] ?= '/usr/hdp/current/hadoop-mapreduce-client'
      hue.ini['hadoop']['yarn_clusters']['default']['hadoop_bin'] ?= '/usr/hdp/current/hadoop-client/bin/hadoop'
      hue.ini['hadoop']['yarn_clusters']['default']['hadoop_conf_dir'] ?= hadoop_conf_dir
      hue.ini['hadoop']['yarn_clusters']['default']['resourcemanager_api_url'] ?= yarn_api_url
      hue.ini['hadoop']['yarn_clusters']['default']['resourcemanager_rpc_url'] ?= rm_rpc_url
      hue.ini['hadoop']['yarn_clusters']['default']['proxy_api_url'] ?= yarn_api_url
      hue.ini['hadoop']['yarn_clusters']['default']['node_manager_api_url'] ?= node_manager_api_url
      # JHS
      jhs_ctx = ctx.contexts('ryba/hadoop/mapred_jhs')[0]
      jhs_protocol = if jhs_ctx.config.ryba.mapred.site['mapreduce.jobhistory.http.policy'] is 'HTTP' then 'http' else 'https'
      jhs_port = if jhs_protocol is 'http'
      then jhs_ctx.config.ryba.mapred.site['mapreduce.jobhistory.webapp.address'].split(':')[1]
      else jhs_ctx.config.ryba.mapred.site['mapreduce.jobhistory.webapp.https.address'].split(':')[1]
      hue.ini['hadoop']['yarn_clusters']['default']['history_server_api_url'] ?= "#{jhs_protocol}://#{jhs_ctx.config.host}:#{jhs_port}"
      # Configure components
      hue.ini['liboozie'] ?= {}
      hue.ini['liboozie']['oozie_url'] ?= ryba.oozie.site['oozie.base.url']
      hue.ini['hcatalog'] ?= {}
      hue.ini['hcatalog']['templeton_url'] ?= templeton_url
      hue.ini['beeswax'] ?= {}
      # HCatalog
      [hs2_ctx] = ctx.contexts 'ryba/hive/server2', require('../hive/server2').configure
      throw Error "No Hive HCatalog Server configured" unless hs2_ctx
      hue.ini['beeswax']['hive_server_host'] ?= "#{hs2_ctx.config.host}"
      hue.ini['beeswax']['hive_server_port'] ?= if hs2_ctx.config.ryba.hive.site['hive.server2.transport.mode'] is 'binary'
      then hs2_ctx.config.ryba.hive.site['hive.server2.thrift.port']
      else hs2_ctx.config.ryba.hive.site['hive.server2.thrift.http.port']
      hue.ini['beeswax']['hive_conf_dir'] ?= "#{ctx.config.ryba.hive.conf_dir}" # Hive client is a dependency of Hue
      hue.ini['beeswax']['server_conn_timeout'] ?= "240"
      # Desktop
      hue.ini['desktop'] ?= {}
      hue.ini['desktop']['django_debug_mode'] ?= '0' # Disable debug by default
      hue.ini['desktop']['http_500_debug_mode'] ?= '0' # Disable debug by default
      hue.ini['desktop']['http'] ?= {}
      hue.ini['desktop']['http_host'] ?= '0.0.0.0'
      hue.ini['desktop']['http_port'] ?= '8888'
      hue.ini['desktop']['secret_key'] ?= 'jFE93j;2[290-eiwMYSECRTEKEYy#e=+Iei*@Mn<qW5o'
      hue.ini['desktop']['smtp'] ?= {}
      hue.ini['desktop']['time_zone'] ?= 'ETC/UTC'
      # Desktop database
      hue.ini['desktop']['database'] ?= {}
      hue.ini['desktop']['database']['engine'] ?= db_admin.engine
      hue.ini['desktop']['database']['host'] ?= db_admin.host
      hue.ini['desktop']['database']['port'] ?= db_admin.port
      hue.ini['desktop']['database']['user'] ?= 'hue'
      hue.ini['desktop']['database']['password'] ?= 'hue123'
      hue.ini['desktop']['database']['name'] ?= 'hue'
      # Kerberos
      hue.ini.desktop.kerberos ?= {}
      hue.ini.desktop.kerberos.hue_keytab ?= '/etc/hue/conf/hue.service.keytab'
      hue.ini.desktop.kerberos.hue_principal ?= "hue/#{ctx.config.host}@#{ryba.realm}"
      # Path to kinit
      # For RHEL/CentOS 5.x, kinit_path is /usr/kerberos/bin/kinit
      # For RHEL/CentOS 6.x, kinit_path is /usr/bin/kinit
      hue.ini['desktop']['kerberos']['kinit_path'] ?= '/usr/bin/kinit'
      # Uncomment all security_enabled settings and set them to true
      hue.ini.hadoop ?= {}
      hue.ini.hadoop.hdfs_clusters ?= {}
      hue.ini.hadoop.hdfs_clusters.default ?= {}
      hue.ini.hadoop.hdfs_clusters.default.security_enabled = 'true'
      hue.ini.hadoop.mapred_clusters ?= {}
      hue.ini.hadoop.mapred_clusters.default ?= {}
      hue.ini.hadoop.mapred_clusters.default.security_enabled = 'true'
      hue.ini.hadoop.yarn_clusters ?= {}
      hue.ini.hadoop.yarn_clusters.default ?= {}
      hue.ini.hadoop.yarn_clusters.default.security_enabled = 'true'
      hue.ini.liboozie ?= {}
      hue.ini.liboozie.security_enabled = 'true'
      hue.ini.hcatalog ?= {}
      hue.ini.hcatalog.security_enabled = 'true'

## Commands

    module.exports.push commands: 'backup', modules: 'ryba/hue/backup'

    # module.exports.push commands: 'check', modules: 'ryba/hue/check'

    module.exports.push commands: 'install', modules: 'ryba/hue/install'

    module.exports.push commands: 'start', modules: 'ryba/hue/start'

    module.exports.push commands: 'status', modules: 'ryba/hue/status'

    module.exports.push commands: 'stop', modules: 'ryba/hue/stop'

[home]: http://gethue.com
