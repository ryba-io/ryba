
export default
  deps:
    proxy: module: 'masson/core/proxy', local: true
    users: module: 'masson/core/users', local: true
    git: module: 'masson/commons/git', local: true
  configure:
    '@rybajs/system/nodejs/configure'
  commands:
    install:
      '@rybajs/system/nodejs/install'
