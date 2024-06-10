
export default
  header: 'Authconfig Install'
  handler: ({options}) ->

    @service
      header: 'Package'
      name: 'authconfig'
    @system.authconfig
      header: 'Configuration'
      config: options.config
