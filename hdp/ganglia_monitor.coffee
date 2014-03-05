
glob = require 'glob'
module.exports = []

module.exports.push 'phyla/core/yum'

###
Ganglia Monitor
================

Ganglia Monitor is the agent to be deployed on each of the hosts.
###
module.exports.push module.exports.configure = (ctx) ->
  # nothing for now

module.exports.push name: 'Ganglia Monitor # Service', timeout: -1, callback: (ctx, next) ->
  ctx.service
    name: 'ganglia-gmond-3.5.0-99'
  , (err, serviced) ->
    next err, if serviced then ctx.OK else ctx.PASS

module.exports.push name: 'Ganglia Monitor # Layout', timeout: -1, callback: (ctx, next) ->
  ctx.mkdir
    destination: '/usr/libexec/hdp/ganglia'
  , (err, created) ->
    next err, if created then ctx.OK else ctx.PASS

module.exports.push name: 'Ganglia Monitor # Objects', timeout: -1, callback: (ctx, next) ->
  glob "#{__dirname}/files/ganglia/objects/*.*", (err, files) ->
    files = for file in files then source: file, destination: "/usr/libexec/hdp/ganglia/", mode: 0o744
    ctx.upload files, (err, uploaded) ->
      next err, if uploaded then ctx.OK else ctx.PASS

module.exports.push name: 'Ganglia Monitor # Init Script', timeout: -1, callback: (ctx, next) ->
  ctx.upload
    source: "#{__dirname}/files/ganglia/scripts/hdp-gmond"
    destination: '/etc/init.d'
    mode: 0o755
  , (err, uploaded) ->
    next err, if uploaded then ctx.OK else ctx.PASS

module.exports.push name: 'Ganglia Monitor # Host', timeout: -1, callback: (ctx, next) ->
  cmds = []
  # If HBase is installed, on the HBase Master
  # this seems to be an error, we moved it to the ganglia master collector
  # if ctx.has_any_modules 'phyla/hdp/hbase_master'
  #  cmds.push cmd: "/usr/libexec/hdp/ganglia/setupGanglia.sh -c HDPHBaseMaster -m"
  # On the NameNode and SecondaryNameNode servers, to configure the gmond emitters
  if ctx.has_any_modules 'phyla/hdp/hdfs_nn', 'phyla/hdp/hdfs_snn'
    cmds.push cmd: "/usr/libexec/hdp/ganglia/setupGanglia.sh -c HDPNameNode"
  # On the ResourceManager server, to configure the gmond emitters
  if ctx.has_any_modules 'phyla/hdp/yarn_rm'
    cmds.push cmd: "/usr/libexec/hdp/ganglia/setupGanglia.sh -c HDPResourceManager"
  # On all hosts, to configure the gmond emitters
  if ctx.has_any_modules 'phyla/hdp/hdfs_dn', 'phyla/hdp/yarn_nm'
    cmds.push cmd: "/usr/libexec/hdp/ganglia/setupGanglia.sh -c HDPSlaves"
  # If HBase is installed, on the HBase Master, to configure the gmond emitter
  if ctx.has_any_modules 'phyla/hdp/hbase_master'
    cmds.push cmd: "/usr/libexec/hdp/ganglia/setupGanglia.sh -c HDPHBaseMaster"
  ctx.execute cmds, (err, executed) ->
    next err, if executed then ctx.OK else ctx.PASS

module.exports.push name: 'Ganglia Monitor # Configuration', timeout: -1, callback: (ctx, next) ->
  collector = ctx.host_with_module 'phyla/hdp/ganglia_collector'
  writes = []
  if ctx.has_any_modules 'phyla/hdp/hdfs_nn', 'phyla/hdp/hdfs_snn'
    writes.push
      destination: "/etc/ganglia/hdp/HDPNameNode/conf.d/gmond.slave.conf"
      match: /^(.*)host = (.*)$/mg
      replace: "$1host = #{collector}"
  # On the ResourceManager server, to configure the gmond emitters
  if ctx.has_any_modules 'phyla/hdp/yarn_rm'
    writes.push
      destination: "/etc/ganglia/hdp/HDPResourceManager/conf.d/gmond.slave.conf"
      match: /^(.*)host = (.*)$/mg
      replace: "$1host = #{collector}"
  # On all hosts, to configure the gmond emitters
  if ctx.has_any_modules 'phyla/hdp/hdfs_dn', 'phyla/hdp/yarn_nm'
    writes.push
      destination: "/etc/ganglia/hdp/HDPSlaves/conf.d/gmond.slave.conf"
      match: /^(.*)host = (.*)$/mg
      replace: "$1host = #{collector}"
  # If HBase is installed, on the HBase Master, to configure the gmond emitter
  if ctx.has_any_modules 'phyla/hdp/hbase_master'
    writes.push
      destination: "/etc/ganglia/hdp/HDPHBaseMaster/conf.d/gmond.slave.conf"
      match: /^(.*)host = (.*)$/mg
      replace: "$1host = #{collector}"
  ctx.write writes, (err, written) ->
    next err, if written then ctx.OK else ctx.PASS

module.exports.push name: 'Ganglia Monitor # Hadoop', callback: (ctx, next) ->
  collector = ctx.host_with_module 'phyla/hdp/ganglia_collector'
  ctx.write
    source: "#{__dirname}/files/core_hadoop/hadoop-metrics2.properties-GANGLIA"
    local_source: true
    destination: "/etc/hadoop/conf/hadoop-metrics2.properties"
    match: "TODO-GANGLIA-SERVER"
    replace: collector
  , (err, written) ->
    next err, if written then ctx.OK else ctx.PASS








