
export default
  use:
    yum: module: 'masson/core/yum'
  configure:
    '@rybajs/system/authconfig/configure'
  commands:
    'install':
      '@rybajs/system/authconfig/install'
