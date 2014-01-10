
lifecycle = require './hdp/lifecycle'
module.exports = []

module.exports.push 'histi/actions/hdp_hdfs'

module.exports.push (ctx) ->
  require('./hdp_hdfs').configure ctx

module.exports.push (ctx, next) ->
  {realm, kadmin_principal, kadmin_password, kadmin_server} = ctx.config.krb5_client
  @name 'HDP HDFS SNN # Kerberos'
  ctx.krb5_addprinc 
    principal: "nn/#{ctx.config.host}@#{realm}"
    randkey: true
    keytab: "/etc/security/keytabs/nn.service.keytab"
    uid: 'hdfs'
    gid: 'hadoop'
    kadmin_principal: kadmin_principal
    kadmin_password: kadmin_password
    kadmin_server: kadmin_server
  , (err, created) ->
    next err, if created then ctx.OK else ctx.PASS

module.exports.push (ctx, next) ->
  @name 'HDP HDFS SNN # Start'
  lifecycle.snn_start ctx, (err, started) ->
    next err, if started then ctx.OK else ctx.PASS