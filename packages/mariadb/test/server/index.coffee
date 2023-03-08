
nikita = require 'nikita'
registry = require '@nikitajs/core/lib/registry'
each = require 'each'
store = require 'masson/lib/config/store'
array_get = require 'masson/lib/utils/array_get'
{cluster} = require '../../env'
{mariadb} = require '../test'

describe 'MariaDB installation - Functional tests (may take 10+ minutes)', ->

  @timeout 1500000 # Extended timeout for these lengthy test
        
  it 'Default configuration', ->
    nikita ->
      await registry.register 'setup', ->
        config = mariadb.default
        params = command: [ 'clusters', 'install' ], config: config
        command = params.command.slice(-1)[0]
        s = store(config)
        await each s.nodes()
        .parallel true
        .call (node, callback) ->
          services = node.services
          await nikita config, ->
            await @ssh.open config.nikita.ssh
            await @call ->
              for service in services
                service = s.service service.cluster, service.service
                instance = array_get service.instances, (instance) -> instance.node.id is node.id
                for module in service.commands[command]
                  isRoot = config.nikita.ssh.username is 'root' or not config.nikita.ssh.username
                  await @call module, instance.options, $debug: true, $sudo: not isRoot, ssh: config.nikita.ssh
            await @ssh.close()
      await registry.register 'test', ->
        {stdout} = await @lxc.exec
          container: 'node1'
          command: """
          mysql --password=secret -e "SHOW DATABASES;"
          """
        stdout.should.eql 'Database\ninformation_schema\nmysql\nperformance_schema\n'
      try
        await @cluster.clean()
        await @cluster.create()
        await @setup()
        await @test()
      catch err
        await @cluster.clean()
      finally
        await @cluster.clean()
