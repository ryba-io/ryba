
export default
  deps:
    iptables: module: 'masson/core/iptables', local: true
    ssl: module: '@rybajs/tools/ssl', local: true
  configure:
    '@rybajs/mariadb/server/configure'
  commands:
    'check':
      '@rybajs/mariadb/server/check'
    'install': [
      '@rybajs/mariadb/server/install'
      '@rybajs/mariadb/server/replication'
      '@rybajs/mariadb/server/check'
    ]
    'stop':
      '@rybajs/mariadb/server/stop'
    'start':
      '@rybajs/mariadb/server/start'
