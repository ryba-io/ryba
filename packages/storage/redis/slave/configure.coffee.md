
# Configure redis

Redis cluster replication adopts a slave-master architecture. This module configure the master
that slave will link to.

    export default ({deps, node, options}) ->

## Identities

The Redis package does create the redis user.

      # Group
      options.group = name: options.group if typeof options.group is 'string'
      options.group ?= {}
      options.group.name ?= 'redis'
      options.group.system ?= true
      # User
      options.user = name: options.user if typeof options.user is 'string'
      options.user ?= {}
      options.user.name ?= 'redis'
      options.user.system ?= true
      options.user.comment ?= 'Redis Database Server'
      options.user.home ?= "/var/lib/#{options.user.name}"
      options.user.groups ?= []
      options.user.gid = options.group.name

## Master Configuration

      # Misc
      options.fqdn ?= node.fqdn
      options.hostname = node.hostname
      options.iptables ?= deps.iptables and deps.iptables.options.action is 'start'
      options.clean_logs ?= false
      options.conf_dir ?= "/etc/redis"
      options.pid_dir ?= '/var/run/redis'
      options.log_dir ?= '/var/log/redis'
      
## Configuration

      options.conf ?= {}
      options.conf['port'] ?= '6379'
      options.conf['pidfile'] ?= "#{options.pid_dir}/redis.pid"
      options.conf['daemonize'] ?= 'no'
      options.conf['tcp-backlog'] ?= '511' #somaxconn #tcp_max_syn_backlog
      options.conf['bind'] ?= '0.0.0.0'
      options.conf['timeout'] ?= '0'
      options.conf['loglevel'] ?= 'notice'
      options.conf['logfile'] ?= "#{options.log_dir}/redis.log"
      options.conf['databases'] ?= '16'
      
## Snapshotting
      
      options.conf['save'] ?= '900 1' #save <seconds> <changes>
      options.conf['stop-writes-on-bgsave-error'] ?= 'yes'
      options.conf['rdbcompression'] ?= 'yes'
      options.conf['rdbchecksum'] ?= 'yes'
      options.conf['dbfilename'] ?= 'dump.rdb'
      options.conf['dir'] ?= "#{options.user.home}/snapshots"

## Replication
Options by default configured from [Redis Official][redis-replication] documentation
      
      options.conf['slave-serve-stale-data'] ?= 'yes'
      options.conf['min-slaves-to-write'] ?= '1'
      options.conf['min-slaves-max-lag'] ?= '30'

## Security
Add password authentication
      
      options.slave_password ?= 'redis123'
      throw Error 'Missing Redis master password' unless options.slave_password?
      options.conf['requirepass'] ?= options.slave_password
      options.conf['slaveof'] ?= "#{deps.redis_master[0].node.fqdn} #{deps.redis_master[0].options.conf['port']}"
      options.conf['masterauth'] ?= "#{deps.redis_master[0].options.conf['requirepass']}"

## Dependencies

    quote = require 'regexp-quote'

[redis-replication]:https://redis.io/topics/replication
