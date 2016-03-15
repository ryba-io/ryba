
# Shinken Configure

*   `shinken.user` (object|string)
    The Unix Shinken login name or a user object (see Mecano User documentation).
*   `shinken.group` (object|string)
    The Unix Shinken group name or a group object (see Mecano Group documentation).

Example

```json
    "shinken":{
      "user": {
        "name": "shinken", "system": true, "gid": "shinken",
        "comment": "Shinken User"
      },
      "group": {
        "name": "shinken", "system": true
      }
    }
```

    module.exports = handler: ->
      shinken = @config.ryba.shinken ?= {}
      shinken.log_dir = '/var/log/shinken'
      shinken.plugin_dir ?= '/usr/lib64/nagios/plugins'
      # User
      shinken.user = name: shinken.user if typeof shinken.user is 'string'
      shinken.user ?= {}
      shinken.user.name ?= 'nagios'
      shinken.user.system ?= true
      shinken.user.comment ?= 'Nagios/Shinken User'
      shinken.user.home ?= '/var/lib/shinken'
      shinken.user.shell ?= '/bin/sh'
      shinken.user.groups ?= ['docker']
      # Groups
      shinken.group = name: shinken.group if typeof shinken.group is 'string'
      shinken.group ?= {}
      shinken.group.name ?= 'nagios'
      shinken.group.system ?= true
      shinken.user.gid = shinken.group.name
      # Config
      shinken.config ?= {}
      shinken.config.use_ssl ?= '0'
      shinken.config.hard_ssl_name_check ?= '0'