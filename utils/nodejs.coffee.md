
###

NodeJs
======

Deploy multiple version of [NodeJs] using [N].

It depends on the "phyla/core/git" and "phyla/utils/users" modules. The former
is used to download n and the latest is used to write a "~/.npmrc" file in the
home of each users.

    ini = require 'ini'
    each = require 'each'
    mecano = require 'mecano'
    misc = require 'mecano/lib/misc'
    module.exports = []
    module.exports.push 'phyla/utils/git'
    module.exports.push 'phyla/core/users'

## Configuration

*   `nodejs.version` (string)   
    Any NodeJs version with the addition of "latest" and "stable", see the [N] 
    documentation for more information, default to "stable".
*   `nodejs.merge` (boolean)   
    Merge the properties defined in "nodejs.config" with the one present on
    the existing "~/.npmrc" file, default to true
*   `nodejs.http_proxy` (string)
    The HTTP proxy connection url, default to the one defined by the 
    "phyla/core/proxy" module.
*   `nodejs.https_proxy` (string)
    The HTTPS proxy connection url, default to the one defined by the 
    "phyla/core/proxy" module.
*   `nodejs.version` (string)
*   `nodejs.version` (string)

Example:

```json
{
  "nodejs": {
    "version": "stable",
    "config": {
      "registry": "http://some.aternative.registry"
    }
  }
}
```

    module.exports.push (ctx, next) ->
      require('../core/proxy').configure ctx
      ctx.config.nodejs ?= {}
      ctx.config.nodejs.version ?= 'stable'
      ctx.config.nodejs.merge ?= true
      ctx.config.nodejs.http_proxy ?= ctx.config.proxy.http_proxy
      ctx.config.nodejs.https_proxy ?= ctx.config.proxy.https_proxy
      ctx.config.nodejs.config ?= {}
      ctx.config.nodejs.config.registry ?= 'http://registry.npmjs.org/'
      next()

## N Installation

N is a Node.js binary management system, similar to nvm and nave.

    module.exports.push name: 'Node.js # N', timeout: 100000, callback: (ctx, next) ->
      # Accoring to current test, proxy env var arent used by ssh exec
      {http_proxy, https_proxy} = ctx.config.nodejs
      env = {}
      env.http_proxy = http_proxy if http_proxy
      env.https_proxy = https_proxy if https_proxy
      ctx.execute
        env: env
        cmd: """
        export http_proxy=#{http_proxy or ''}
        export https_proxy=#{http_proxy or ''}
        cd /tmp
        git clone https://github.com/visionmedia/n.git
        cd n
        make install
        """
        not_if_exists: '/usr/local/bin/n'
      , (err, executed) ->
        next err, if executed then ctx.OK else ctx.PASS

## Node.js Installation

Multiple installation of Node.js may coexist with N.

    module.exports.push name: 'Node.js # installation', timeout: -1, callback: (ctx, next) ->
      ctx.execute
        cmd: "n #{ctx.config.nodejs.version}"
      , (err, executed) ->
        next err, if executed is 0 then ctx.OK else ctx.PASS


## NPM configuration

Write the "~/.npmrc" file for each user defined by the "phyla/core/users" 
module.

    module.exports.push name: 'Node.js # Npm Configuration', timeout: -1, callback: (ctx, next) ->
      written = 0
      each(ctx.config.users)
      .on 'item', (user, next) ->
        return next() unless user.home
        file = "#{user.home}/.npmrc"
        remoteConfig = {}
        get = ->
          return write() unless ctx.config.nodejs.merge
          misc.file.readFile ctx.ssh, file, (err, config) ->
            return next err if err and err.code isnt 'ENOENT'
            config ?= ''
            config = ini.parse config
            remoteConfig = config
            write()
        write = ->
          config = ctx.config.nodejs.config
          if ctx.config.nodejs.proxy
            config.proxy = ctx.config.nodejs.proxy
          else 
            delete remoteConfig.proxy
          misc.merge remoteConfig, config
          config = ini.stringify config
          ctx.write
            destination: file
            content: config
            uid: user.username
            gid: null
          , (err, w) ->
            written++ if w
            next err
        get()
      .on 'both', (err) ->
        next err, if written then ctx.OK else ctx.PASS

[nodejs]: http://www.nodejs.org
[n]: https://github.com/visionmedia/n

