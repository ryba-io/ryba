
url = require 'url'

module.exports = []
module.exports.push 'phyla/core/yum'
module.exports.push 'phyla/hdp/core'

###
Note about upgrade from 1.3.x to 2.x, once we install 
the new repo, yum update failed. We should first remove 
some package, here's how: `yum remove hadoop-native hadoop-pipes hadoop-sbin`.
###
module.exports.push module.exports.configure = (ctx) ->
  return if ctx.hdfs_configured
  ctx.hdfs_configured = true
  require('./core').configure ctx
  require('../core/nc').configure ctx
  {nameservice} = ctx.config.hdp
  namenodes = ctx.hosts_with_module 'phyla/hdp/hdfs_nn'
  # Define Directories for Core Hadoop
  ctx.config.hdp.dfs_name_dir ?= ['/hadoop/hdfs/namenode']
  ctx.config.hdp.dfs_name_dir = ctx.config.hdp.dfs_name_dir.split ',' if typeof ctx.config.hdp.dfs_name_dir is 'string'
  ctx.config.hdp.dfs_data_dir ?= ['/hadoop/hdfs/data']
  ctx.config.hdp.dfs_data_dir = ctx.config.hdp.dfs_data_dir.split ',' if typeof ctx.config.hdp.dfs_data_dir is 'string'
  ctx.config.hdp.hdfs_user ?= 'hdfs'
  throw new Error "Missing value for 'hdfs_password'" unless ctx.config.hdp.hdfs_password?
  ctx.config.hdp.test_user ?= 'test'
  throw new Error "Missing value for 'test_password'" unless ctx.config.hdp.test_password?
  ctx.config.hdp.fs_checkpoint_dir ?= ['/hadoop/hdfs/snn'] # Default ${fs.checkpoint.dir}
  # Options and configuration
  ctx.config.hdp.hdfs_namenode_ipc_port ?= '8020'
  ctx.config.hdp.hdfs_namenode_http_port ?= '50070'
  ctx.config.hdp.hdfs_namenode_timeout ?= 20000 # 20s
  ctx.config.hdp.snn_port ?= '50090'
  # Options for "hdfs-site.xml"
  ctx.config.hdp.hdfs_site ?= {}
  # ctx.config.hdp.hdfs_site['dfs.datanode.data.dir.perm'] ?= '750'
  ctx.config.hdp.hdfs_site['dfs.datanode.data.dir.perm'] ?= '700'
  ctx.config.hdp.hdfs_site['dfs.journalnode.edits.dir'] ?= '/var/run/hadoop-hdfs/journalnode_edit_dir'
  ctx.config.hdp.hdfs_site['fs.permissions.umask-mode'] ?= '027' # 0750
  # Options for "hadoop-policy.xml"
  ctx.config.hdp.hadoop_policy ?= {}
  # Options for "hadoop-env.sh"
  ctx.config.hdp.options ?= {}
  ctx.config.hdp.options['java.net.preferIPv4Stack'] ?= true
  # HDFS HA configuration
  ctx.config.hdp.ha_client_config = {}
  ctx.config.hdp.ha_client_config['dfs.nameservices'] = nameservice
  ctx.config.hdp.ha_client_config["dfs.ha.namenodes.#{nameservice}"] = (for nn in namenodes then nn.split('.')[0]).join ','
  for nn in namenodes
    ctx.config.hdp.ha_client_config["dfs.namenode.rpc-address.#{nameservice}.#{nn.split('.')[0]}"] = "#{nn}:8020"
    ctx.config.hdp.ha_client_config["dfs.namenode.http-address.#{nameservice}.#{nn.split('.')[0]}"] = "#{nn}:50070"
  ctx.config.hdp.ha_client_config["dfs.client.failover.proxy.provider.#{nameservice}"] = 'org.apache.hadoop.hdfs.server.namenode.ha.ConfiguredFailoverProxyProvider'

#http://docs.hortonworks.com/HDPDocuments/HDP1/HDP-1.2.3.1/bk_installing_manually_book/content/rpm-chap1-9.html
#http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html#Running_Hadoop_in_Secure_Mode
module.exports.push name: 'HDP HDFS # Users', callback: (ctx, next) ->
  return next() unless ctx.has_any_modules('hisi/hdp/hdfs_nn', 'hisi/hdp/hdfs_snn', 'hisi/hdp/hdfs_dn')
  {hadoop_group} = ctx.config.hdp
  ctx.execute
    cmd: "useradd hdfs -r -M -g #{hadoop_group} -s /bin/bash -c \"Used by Hadoop HDFS service\""
    code: 0
    code_skipped: 9
  , (err, executed) ->
    next err, if executed then ctx.OK else ctx.PASS

module.exports.push name: 'HDP HDFS # Install', timeout: -1, callback: (ctx, next) ->
  ctx.service [
    name: 'hadoop'
  ,
    name: 'hadoop-hdfs'
  ,
    name: 'hadoop-libhdfs'
  ,
    name: 'hadoop-client'
  ,
    name: 'openssl'
  ], (err, serviced) ->
    next err, if serviced then ctx.OK else ctx.PASS

module.exports.push name: 'HDP HDFS # Hadoop Configuration', timeout: -1, callback: (ctx, next) ->
  { core, hdfs_site, yarn,
    hadoop_conf_dir, fs_checkpoint_dir, # fs_checkpoint_edit_dir,
    dfs_name_dir, dfs_data_dir, 
    hdfs_namenode_http_port, snn_port } = ctx.config.hdp #mapreduce_local_dir, 
  datanodes = ctx.hosts_with_module 'phyla/hdp/hdfs_dn'
  secondary_namenode = ctx.hosts_with_module 'phyla/hdp/hdfs_snn', 1
  modified = false
  do_hdfs = ->
    ctx.log 'Configure hdfs-site.xml'
    # Fix: the "dfs.cluster.administrators" value has a space inside
    hdfs_site['dfs.cluster.administrators'] = 'hdfs'
    # Comma separated list of paths. Use the list of directories from $DFS_NAME_DIR.  
    # For example, /grid/hadoop/hdfs/nn,/grid1/hadoop/hdfs/nn.
    hdfs_site['dfs.namenode.name.dir'] ?= dfs_name_dir.join ','
    # Comma separated list of paths. Use the list of directories from $DFS_DATA_DIR.  
    # For example, /grid/hadoop/hdfs/dn,/grid1/hadoop/hdfs/dn.
    hdfs_site['dfs.datanode.data.dir'] ?= dfs_data_dir.join ','
    # NameNode hostname for http access.
    # todo: "dfs.namenode.http-address" is only when not in ha mode, need to detect if we run
    # the cluster in ha or not
    # hdfs_site['dfs.namenode.http-address'] ?= "#{namenode}:#{hdfs_namenode_http_port}"
    hdfs_site['dfs.namenode.http-address'] = null
    # Secondary NameNode hostname
    hdfs_site['dfs.namenode.secondary.http-address'] ?= "hdfs://#{secondary_namenode}:#{snn_port}" if secondary_namenode
    # NameNode hostname for https access
    # latest source code
    hdfs_site['dfs.namenode.https-address'] ?= "hdfs://0.0.0.0:50470"
    # official doc
    # hdfs_site['dfs.https.address'] ?= "hdfs://#{namenodes[0]}:50470"
    hdfs_site['dfs.namenode.checkpoint.dir'] ?= fs_checkpoint_dir.join ','
    ctx.hconfigure
      destination: "#{hadoop_conf_dir}/hdfs-site.xml"
      default: "#{__dirname}/files/core_hadoop/hdfs-site.xml"
      local_default: true
      properties: hdfs_site
      merge: true
    , (err, configured) ->
      return next err if err
      modified = true if configured
      do_master()
  do_master = ->
    # Accoring to [Yahoo!](http://developer.yahoo.com/hadoop/tutorial/module7.html):
    # The conf/masters file contains the hostname of the
    # SecondaryNameNode. This should be changed from "localhost"
    # to the fully-qualified domain name of the node to run the
    # SecondaryNameNode service. It does not need to contain
    # the hostname of the JobTracker/NameNode machine; 
    # Also some [interesting info about snn](http://blog.cloudera.com/blog/2009/02/multi-host-secondarynamenode-configuration/)
    ctx.log 'Configure masters'
    return do_slaves() unless secondary_namenode
    ctx.write
      content: "#{secondary_namenode}"
      destination: "#{hadoop_conf_dir}/masters"
    , (err, configured) ->
      return next err if err
      modified = true if configured
      do_slaves()
  do_slaves = ->
    # The conf/slaves file should contain the hostname of every machine
    # in the cluster which should start TaskTracker and DataNode daemons
    ctx.log 'Configure slaves'
    ctx.write
      content: "#{datanodes.join '\n'}"
      destination: "#{hadoop_conf_dir}/slaves"
    , (err, configured) ->
      return next err if err
      modified = true if configured
      do_end()
  do_end = ->
    next null, if modified then ctx.OK else ctx.PASS
  do_hdfs()

module.exports.push name: 'HDP HDFS # Configure HTTPS', callback: (ctx, next) ->
  {hadoop_conf_dir, hadoop_policy} = ctx.config.hdp
  namenode = ctx.hosts_with_module 'phyla/hdp/hdfs_nn', 1
  modified = false
  do_hdfs_site = ->
    ctx.hconfigure
      destination: "#{hadoop_conf_dir}/hdfs-site.xml"
      properties:
        # Decide if HTTPS(SSL) is supported on HDFS
        # http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.0.5.0/bk_reference/content/ch_wire1.html
        # For now (oct 7th, 2013), we disable it because nn and dn doesnt start
        'dfs.https.enable': 'false'
        'dfs.https.namenode.https-address': "#{namenode}:50470"
        # The https port where NameNode binds
        'dfs.https.port': '50470'
        # The https address where namenode binds. Example: ip-10-111-59-170.ec2.internal:50470
        'dfs.https.address': "#{namenode}:50470"
      merge: true
    , (err, configured) ->
      return next err if err
      modified = true if configured
      do_hadoop_policy()
  do_hadoop_policy = ->
    ctx.log 'Configure hadoop-policy.xml'
    ctx.hconfigure
      destination: "#{hadoop_conf_dir}/hadoop-policy.xml"
      default: "#{__dirname}/files/core_hadoop/hadoop-policy.xml"
      local_default: true
      properties: hadoop_policy
      merge: true
    , (err, configured) ->
      return next err if err
      modified = true if configured
      do_end()
  do_end = ->
    next null, if modified then ctx.OK else ctx.PASS
  do_hdfs_site()

module.exports.push name: 'HDP HDFS # SPNEGO', callback: module.exports.spnego = (ctx, next) ->
  {hdfs_user} = ctx.config.hdp
  {realm, kadmin_principal, kadmin_password, kadmin_server} = ctx.config.krb5_client
  ctx.mkdir
    destination: '/etc/security/keytabs'
    uid: 'root'
    gid: 'hadoop'
    mode: 0o750
  , (err, created) ->
    ctx.log 'Creating HTTP Principals and SPNEGO keytab'
    ctx.krb5_addprinc
      principal: "HTTP/#{ctx.config.host}@#{realm}"
      randkey: true
      keytab: '/etc/security/keytabs/spnego.service.keytab'
      uid: 'hdfs'
      gid: 'hadoop'
      mode: 0o660 # need rw access for hadoop and mapred users
      kadmin_principal: kadmin_principal
      kadmin_password: kadmin_password
      kadmin_server: kadmin_server
    , (err, created) ->
      next err, if created then ctx.OK else ctx.PASS

module.exports.push name: 'HDP HDFS # Kerberos Configure', callback: (ctx, next) ->
  {realm} = ctx.config.krb5_client
  {hadoop_conf_dir} = ctx.config.hdp
  secondary_namenode = ctx.hosts_with_module 'phyla/hdp/hdfs_snn', 1
  hdfs_site = {}
  # If "true", access tokens are used as capabilities
  # for accessing datanodes. If "false", no access tokens are checked on
  # accessing datanodes.
  hdfs_site['dfs.block.access.token.enable'] ?= 'true'
  # Kerberos principal name for the NameNode
  hdfs_site['dfs.namenode.kerberos.principal'] ?= "nn/_HOST@#{realm}"
  # Kerberos principal name for the secondary NameNode.
  hdfs_site['dfs.secondary.namenode.kerberos.principal'] ?= "nn/_HOST@#{realm}"
  # Address of secondary namenode web server
  hdfs_site['dfs.secondary.http.address'] ?= "#{secondary_namenode}:50090" if secondary_namenode # todo, this has nothing to do here
  # The https port where secondary-namenode binds
  hdfs_site['dfs.secondary.https.port'] ?= '50490' # todo, this has nothing to do here
  # The HTTP Kerberos principal used by Hadoop-Auth in the HTTP 
  # endpoint. The HTTP Kerberos principal MUST start with 'HTTP/' 
  # per Kerberos HTTP SPNEGO specification. 
  hdfs_site['dfs.web.authentication.kerberos.principal'] ?= "HTTP/_HOST@#{realm}"
  # The Kerberos keytab file with the credentials for the HTTP 
  # Kerberos principal used by Hadoop-Auth in the HTTP endpoint.
  hdfs_site['dfs.web.authentication.kerberos.keytab'] ?= '/etc/security/keytabs/spnego.service.keytab'
  # The Kerberos principal that the DataNode runs as. "_HOST" is replaced by the real host name.  
  hdfs_site['dfs.datanode.kerberos.principal'] ?= "dn/_HOST@#{realm}"
  # Combined keytab file containing the NameNode service and host principals.
  hdfs_site['dfs.namenode.keytab.file'] ?= '/etc/security/keytabs/nn.service.keytab'
  # Combined keytab file containing the NameNode service and host principals.
  hdfs_site['dfs.secondary.namenode.keytab.file'] ?= '/etc/security/keytabs/nn.service.keytab'
  # The filename of the keytab file for the DataNode.
  hdfs_site['dfs.datanode.keytab.file'] ?= '/etc/security/keytabs/dn.service.keytab'
  # # Default to ${dfs.web.authentication.kerberos.principal}, but documented in hdp 1.3.2 manual install
  hdfs_site['dfs.namenode.kerberos.internal.spnego.principal'] ?= "HTTP/_HOST@#{realm}"
  # # Default to ${dfs.web.authentication.kerberos.principal}, but documented in hdp 1.3.2 manual install
  hdfs_site['dfs.secondary.namenode.kerberos.internal.spnego.principal'] ?= "HTTP/_HOST@#{realm}"
  # The address, with a privileged port - any port number under 1023. Example: 0.0.0.0:1019
  hdfs_site['dfs.datanode.address'] ?= '0.0.0.0:1019'
  # The address, with a privileged port - any port number under 1023. Example: 0.0.0.0:1022
  # update, [official doc propose port 2005 only for https, http is not even documented](http://hadoop.apache.org/docs/current/hadoop-project-dist/hadoop-common/ClusterSetup.html#Configuration_in_Secure_Mode)
  hdfs_site['dfs.datanode.http.address'] ?= '0.0.0.0:1022'
  hdfs_site['dfs.datanode.https.address'] ?= '0.0.0.0:1023'
  # Documented in http://hadoop.apache.org/docs/r2.1.0-beta/hadoop-project-dist/hadoop-common/ClusterSetup.html#Running_Hadoop_in_Secure_Mode
  # Only seems to apply if "dfs.https.enable" is enabled
  hdfs_site['dfs.namenode.kerberos.https.principal'] = "host/_HOST@#{realm}"
  hdfs_site['dfs.secondary.namenode.kerberos.https.principal'] = "host/_HOST@#{realm}"
  ctx.hconfigure
    destination: "#{hadoop_conf_dir}/hdfs-site.xml"
    properties: hdfs_site
    merge: true
  , (err, configured) ->
    next err, if configured then ctx.OK else ctx.PASS







