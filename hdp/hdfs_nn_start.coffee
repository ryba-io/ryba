
lifecycle = require './lib/lifecycle'
mkcmd = require './lib/mkcmd'
module.exports = []

module.exports.push (ctx) ->
  require('./hdfs').configure ctx
  throw Error "Not a NameNode" unless ctx.has_module 'phyla/hdp/hdfs_nn'

module.exports.push name: 'HDP NameNode # Start', callback: (ctx, next) ->
  lifecycle.nn_start ctx, (err, started) ->
    next err, if started then ctx.OK else ctx.PASS

module.exports.push name: 'HDP NameNode # Start ZKFC', callback: (ctx, next) ->
  # ZKFC should start first on active NameNode
  {active_nn, active_nn_host} = ctx.config.hdp
  do_wait = ->
    ctx.waitForExecution
      # hdfs haadmin -getServiceState hadoop1
      cmd: mkcmd.hdfs ctx, "hdfs haadmin -getServiceState #{active_nn_host.split('.')[0]}"
      code_skipped: 255
    , (err, stdout) ->
      return next err if err
      do_start()
  do_start = ->
    lifecycle.zkfc_start ctx, (err, started) ->
      next err, if started then ctx.OK else ctx.PASS
  if active_nn then do_start() else do_wait()
