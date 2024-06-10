
export default
  deps:
    db_admin: module: '@rybajs/tools/db_admin', local: true, auto: true, implicit: true
    iptables: implicit: true, module: 'masson/core/iptables'
    nodejs: module: '@rybajs/system/nodejs', local: true, auto: true, implicit: true
    krb5_client: module: 'masson/core/krb5_client'
    ipa_client: module: 'masson/core/freeipa/client', local: true
  configure:
    '@rybajs/tools/hue/configure'
  commands:
    'backup': [
      '@rybajs/tools/hue/backup'
    ]
    'install': [
      '@rybajs/tools/hue/install'
      '@rybajs/tools/hue/start'
    ]
    'start': [
      '@rybajs/tools/hue/start'
    ]
    'status': [
      '@rybajs/tools/hue/status'
    ]
    'stop': [
      '@rybajs/tools/hue/stop'
    ]
