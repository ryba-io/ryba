
module.exports =
  deps:
    iptables: module: 'masson/core/iptables', local: true
    system: module: 'masson/core/system', local: true #rngd entropy
    ssl: module: '@rybajs/tools/ssl', local: true
    network: module: 'masson/core/network', local: true
    rngd: module: 'masson/core/rngd', local: true, auto: true, implicit: true
  configure:
    'masson/core/freeipa/server/configure'
  commands:
    'check':
      'masson/core/freeipa/server/check'
    'install': [
      'masson/core/freeipa/server/install'
      # 'masson/core/freeipa/server/start'
      # 'masson/core/freeipa/server/check'
    ]
    'start':
      'masson/core/freeipa/server/start'
    'status':
      'masson/core/freeipa/server/status'
    'stop':
      'masson/core/freeipa/server/stop'
