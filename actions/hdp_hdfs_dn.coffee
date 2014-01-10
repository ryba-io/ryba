
lifecycle = require './hdp/lifecycle'
mkcmd = require './hdp/mkcmd'
module.exports = []

module.exports.push 'histi/actions/hdp_hdfs'

module.exports.push (ctx) ->
  require('./hdp_hdfs').configure ctx
  ctx.config.hdp.force_check ?= false

module.exports.push (ctx, next) ->
  {realm, kadmin_principal, kadmin_password, kadmin_server} = ctx.config.krb5_client
  @name 'HDP HDFS DN # Kerberos'
  ctx.krb5_addprinc 
    principal: "dn/#{ctx.config.host}@#{realm}"
    randkey: true
    keytab: "/etc/security/keytabs/dn.service.keytab"
    uid: 'hdfs'
    gid: 'hadoop'
    kadmin_principal: kadmin_principal
    kadmin_password: kadmin_password
    kadmin_server: kadmin_server
  , (err, created) ->
    next err, if created then ctx.OK else ctx.PASS

module.exports.push (ctx, next) ->
  @name 'HDP HDFS DN # Start'
  lifecycle.dn_start ctx, (err, started) ->
    next err, ctx.OK

###
Layout is inspired by [Hadoop recommandation](http://hadoop.apache.org/docs/r2.1.0-beta/hadoop-project-dist/hadoop-common/ClusterSetup.html)
###
module.exports.push (ctx, next) ->
  {hadoop_group, hdfs_user, test_user, yarn, yarn_user, mapred, mapred_user} = ctx.config.hdp
  @name 'HDP HDFS DN # HDFS layout'
  ok = false
  do_root = ->
    ctx.execute
      cmd: mkcmd.hdfs ctx, """
      hdfs dfs -chmod 755 /
      """
    , (err, executed, stdout) ->
      return next err if err
      do_tmp()
  do_tmp = ->
    ctx.execute
      cmd: mkcmd.hdfs ctx, """
      if hdfs dfs -test -d /tmp; then exit 1; fi
      hdfs dfs -mkdir /tmp
      hdfs dfs -chown #{hdfs_user}:#{hadoop_group} /tmp
      hdfs dfs -chmod 777 /tmp
      """
      code_skipped: 1
    , (err, executed, stdout) ->
      return next err if err
      ok = true if executed
      do_user()
  do_user = ->
    ctx.execute
      cmd: mkcmd.hdfs ctx, """
      if hdfs dfs -test -d /user; then exit 1; fi
      hdfs dfs -mkdir /user
      hdfs dfs -chown #{hdfs_user}:#{hadoop_group} /user
      hdfs dfs -chmod 755 /user
      hdfs dfs -mkdir /user/#{hdfs_user}
      hdfs dfs -chown #{hdfs_user}:#{hadoop_group} /user/#{hdfs_user}
      hdfs dfs -chmod 755 /user/#{hdfs_user}
      hdfs dfs -mkdir /user/#{test_user}
      hdfs dfs -chown #{test_user}:#{hadoop_group} /user/#{test_user}
      hdfs dfs -chmod 755 /user/#{test_user}
      """
      code_skipped: 1
    , (err, executed, stdout) ->
      return next err if err
      ok = true if executed
      do_apps()
  do_apps = ->
    ctx.execute
      cmd: mkcmd.hdfs ctx, """
      if hdfs dfs -test -d /apps; then exit 1; fi
      hdfs dfs -mkdir /apps
      hdfs dfs -chown #{hdfs_user}:#{hadoop_group} /apps
      hdfs dfs -chmod 755 /apps
      """
      code_skipped: 1
    , (err, executed, stdout) ->
      return next err if err
      ok = true if executed
      do_end()
  do_end = ->
    next null, if ok then ctx.OK else ctx.PASS
  do_root()

module.exports.push (ctx, next) ->
  {hdfs_user} = ctx.config.hdp
  @name 'HDP HDFS DN # Test HDFS'
  ctx.execute
    cmd: mkcmd.test ctx, """
    if hdfs dfs -test -f /user/test/hdfs_#{ctx.config.host}; then exit 2; fi
    hdfs dfs -put /etc/passwd /user/test/hdfs_#{ctx.config.host}
    """
    code_skipped: 2
  , (err, executed, stdout) ->
    next err, if executed then ctx.OK else ctx.PASS

###
Test WebHDFS
------------
Test the Kerberos SPNEGO and the Hadoop delegation token. Will only be 
executed if the file "/user/test/webhdfs" generated by this action 
is not present on HDFS.

Read [Delegation Tokens in Hadoop Security ](http://www.kodkast.com/blogs/hadoop/delegation-tokens-in-hadoop-security) 
for more information.
###
module.exports.push (ctx, next) ->
  namenode = (ctx.config.servers.filter (s) -> s.hdp?.namenode)[0].host
  {force_check} = ctx.config.hdp
  @name 'HDP HDFS DN # Test WebHDFS'
  @timeout -1
  do_init = ->
    ctx.execute
      cmd: mkcmd.test ctx, """
        if hdfs dfs -test -f /user/test/webhdfs; then exit 2; fi
        hdfs dfs -touchz /user/test/webhdfs
        kdestroy
      """
      code_skipped: 2
    , (err, executed, stdout) ->
      return next err if err
      return do_spnego() if force_check
      return next null, ctx.PASS unless executed
      do_spnego()
  do_spnego = ->
    ctx.execute
      cmd: mkcmd.test ctx, """
      curl -s --negotiate -u : "http://#{namenode}:50070/webhdfs/v1/user/test?op=LISTSTATUS"
      kdestroy
      """
    , (err, executed, stdout) ->
      return next err if err
      count = JSON.parse(stdout).FileStatuses.FileStatus.filter((e) -> e.pathSuffix is 'webhdfs').length
      return next null, ctx.FAILED unless count
      do_token()
  do_token = ->
    ctx.execute
      cmd: mkcmd.test ctx, """
      curl -s --negotiate -u : "http://#{namenode}:50070/webhdfs/v1/?op=GETDELEGATIONTOKEN"
      kdestroy
      """
    , (err, executed, stdout) ->
      return next err if err
      token = JSON.parse(stdout).Token.urlString
      ctx.execute
        cmd: """
        curl -s "http://#{namenode}:50070/webhdfs/v1/user/test?delegation=#{token}&op=LISTSTATUS"
        """
      , (err, executed, stdout) ->
        return next err if err
        count = JSON.parse(stdout).FileStatuses.FileStatus.filter((e) -> e.pathSuffix is 'webhdfs').length
        return next null, ctx.FAILED unless count
        do_end()
  do_end = ->
    next null, ctx.OK
  do_init()






