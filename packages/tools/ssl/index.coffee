
export default
  deps:
    'java': module: 'masson/commons/java'
    'freeipa': module: 'masson/core/freeipa/client', local: true
  configure:
    '@rybajs/tools/ssl/configure'
  commands:
    'install':
      '@rybajs/tools/ssl/install'
