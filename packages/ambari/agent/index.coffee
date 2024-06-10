
export default
  deps:
    java: module: '@rybajs/system/java', local: true, recommanded: true
    ambari_server: module: '@rybajs/ambari/server', required: true
    ambari_repo: module: '@rybajs/ambari/repo', local: true, auto: true, implicit: true
    ambari_agent: module: '@rybajs/ambari/agent'
    # local_agent: module: '@rybajs/agent', local: true, required: true
  configure:
    '@rybajs/ambari/agent/configure'
  commands:
    'check':
      '@rybajs/ambari/agent/check'
    'install': [
      '@rybajs/ambari/agent/install'
      '@rybajs/ambari/agent/start'
      '@rybajs/ambari/agent/check'
    ]
    'start':
      '@rybajs/ambari/agent/start'
    'stop':
      '@rybajs/ambari/agent/stop'
