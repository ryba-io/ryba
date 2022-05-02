
###
YUM
===
###

each = require 'each'
path = require 'path'
misc = require 'mecano/lib/misc'
ini = require 'ini'

module.exports = []

###
Dependencies: proxy
###
module.exports.push 'phyla/core/proxy'
module.exports.push 'phyla/core/network'

###
Configuration
-------------

*   `clean`
*   `copy`
    Deploy the YUM repository definitions files.
*   `merge`
*   `proxy`   
    Inject proxy configuration as declared in the proxy 
    action, default is true
*   `update`
    Update packages on the system
###
module.exports.push module.exports.configure = (ctx) ->
  require('./proxy').configure ctx
  ctx.config.yum ?= {}
  ctx.config.yum.clean ?= false
  ctx.config.yum.copy ?= null
  ctx.config.yum.merge ?= true
  ctx.config.yum.update ?= true
  ctx.config.yum.proxy ?= true
  ctx.config.yum.config ?= {}
  ctx.config.yum.config.main ?= {}
  ctx.config.yum.config.main.keepcache ?= '1'
  {http_proxy_no_auth, username, password} = ctx.config.proxy
  if ctx.config.yum.proxy
    ctx.config.yum.config.main.proxy = http_proxy_no_auth
    ctx.config.yum.config.main.proxy_username = username
    ctx.config.yum.config.main.proxy_password = password

module.exports.push name: 'YUM # Check', callback: (ctx, next) ->
  ctx.log 'Check if YUM is running'
  pidfile = '/var/run/yum.pid'
  opts = {}
  # opts = 
  #   stdout: ctx.log.out
  #   stderr: ctx.log.err
  misc.pidfileStatus ctx.ssh, pidfile, opts, (err, status) ->
    return next err if err
    if status is 0
      ctx.log 'YUM is running, abort'
      next new Error 'Yum is already running'
    if status is 1
      ctx.log 'YUM isnt running'
      next null, ctx.PASS
    if status is 2
      ctx.log "YUM isnt running, removing invalid #{pidfile}"
      next null, ctx.OK

###
YUM # Configuration
-----------
Read the existing configuration in '/etc/yum.conf', 
merge server configuration and write the content back.

More information about configuring the proxy settings 
is available on [the centos website](http://www.centos.org/docs/5/html/yum/sn-yum-proxy-server.html)
###
module.exports.push name: 'YUM # Configuration', callback: (ctx, next) ->
  {config} = ctx.config.yum
  ctx.log 'Update configuration'
  ctx.ini
    content: config
    destination: '/etc/yum.conf'
    merge: true
    backup: true
  , (err, written) ->
    next err, if written then ctx.OK else ctx.PASS

###
YUM # repositories
------------------
Upload the YUM repository definitions files present in 
"ctx.config.yum.copy" to the yum repository directory 
in "/etc/yum.repos.d"
###
module.exports.push name: 'YUM # Repositories', timeout: -1, callback: (ctx, next) ->
  {copy, clean} = ctx.config.yum
  return next null, ctx.DISABLED unless copy
  modified = false
  basenames = []
  do_upload = ->
    each()
    .files(copy)
    .parallel(10)
    .on 'item', (filename, next) ->
      basename = path.basename filename
      return next() if basename.indexOf('.') is 0
      basenames.push basename
      ctx.log "Upload /etc/yum.repos.d/#{path.basename filename}"
      ctx.upload
        source: filename
        destination: "/etc/yum.repos.d/#{path.basename filename}"
      , (err, uploaded) ->
        return next err if err
        modified = true if uploaded
        next()
    .on 'error', (err) ->
      next err
    .on 'end', ->
      do_clean()
  do_clean = ->
    return do_update() unless clean
    ctx.log "Clean /etc/yum.repos.d/*"
    misc.file.readdir ctx.ssh, '/etc/yum.repos.d', (err, remote_basenames) ->
      return next err if err
      remove_basenames = []
      for rfn in remote_basenames
        continue if rfn.indexOf('.') is 0
        # Add to the stack if remote filename isnt in source
        remove_basenames.push rfn if basenames.indexOf(rfn) is -1
      return do_update() if remove_basenames.length is 0
      each(remove_basenames)
      .on 'item', (filename, next) ->
        misc.file.unlink ctx.ssh, "/etc/yum.repos.d/#{filename}", next
      .on 'error', (err) ->
        next err
      .on 'end', ->
        modified = true
        do_update()
  do_update = ->
    return next null, ctx.PASS unless modified
    ctx.log 'Clean metadata and update'
    ctx.execute
      cmd: 'yum clean metadata; yum -y update'
    , (err, executed) ->
      next err, ctx.OK
  do_upload()

module.exports.push name: 'YUM # Update', timeout: -1, callback: (ctx, next) ->
  {update} = ctx.config.yum
  return next null, ctx.DISABLED unless update
  ctx.execute
    cmd: 'yum -y update'
  , (err, executed, stdout, stderr) ->
    next err, if /No Packages marked for Update/.test(stdout) then ctx.PASS else ctx.OK




