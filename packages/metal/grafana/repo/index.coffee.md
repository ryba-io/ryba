
# Grafana Repository

    export default
      deps: {}
      configure:
        '@rybajs/metal/grafana/repo/configure'
      commands:
        'install':
          '@rybajs/metal/grafana/repo/install'
        'prepare':
          '@rybajs/metal/grafana/repo/prepare'
