
path = require 'path'
nikita = require 'nikita'
{env, tags} = require './test'
{cluster} = require '../env'


describe 'Test environment', ->

  @timeout 1500000 # Extended timeout for these lengthy test

  describe 'Cluster status', ->

    it 'Up and running', ->
      nikita ->
        await @cluster.clean()
        await @cluster.create()
        {config} = await @lxc.state
          $header: 'Nikita'
          container: 'nikita'
        config.status.should.eql 'Running'
        {config} = await @lxc.state
          $header: 'Node 1'
          container: 'node1'
        config.status.should.eql 'Running'
        {config} = await @lxc.state
          $header: 'Node 2'
          container: 'node2'
        config.status.should.eql 'Running'
        await @cluster.clean()


  describe 'Cluster network', ->

    it 'Private IP', ->
      nikita ->
        await @cluster.clean()
        await @cluster.create()
        {$status} = await @execute
          command: """
          ping -c 1 #{env.nic.node1.eth1['ipv4.address']}
          """
        $status.should.be.true()
        {$status} = await @execute
          command: """
          ping -c 1 #{env.nic.node2.eth1['ipv4.address']}
          """
        $status.should.be.true()
        await @cluster.clean()

  return unless tags.ssl

  describe 'SSL', ->

    it 'Local and remote certificates', ->
      nikita ->
        await @cluster.clean()
        await @cluster.create()
        await @fs.assert
          target: path.join __dirname, '../env/assets/cert/server.cert.pem'
        await @fs.assert
          target: path.join __dirname, '../env/assets/cert/server.key.pem'
        await @fs.assert
          target: path.join __dirname, '../env/assets/cert/client.cert.pem'
        await @fs.assert
          target: path.join __dirname, '../env/assets/cert/client.key.pem'
        await @fs.assert
          target: path.join __dirname, '../env/assets/cert/ca.cert.pem'
        await @fs.assert
          target: path.join __dirname, '../env/assets/cert/ca.key.pem'
        # node1: server
        {exists} = await @lxc.file.exists
          container: 'node1'
          target: '/etc/ssl/server.cert.pem'
        exists.should.be.true()
        {exists} = await @lxc.file.exists
          container: 'node1'
          target: '/etc/ssl/server.key.pem'
        exists.should.be.true()
        {exists} = await @lxc.file.exists
          container: 'node1'
          target: '/etc/ssl/ca.cert.pem'
        exists.should.be.true()
        # node2: client
        {exists} = await @lxc.file.exists
          container: 'node2'
          target: '/etc/ssl/client.cert.pem'
        exists.should.be.true()
        {exists} = await @lxc.file.exists
          container: 'node2'
          target: '/etc/ssl/client.key.pem'
        exists.should.be.true()
        {exists} = await @lxc.file.exists
          container: 'node2'
          target: '/etc/ssl/ca.cert.pem'
        exists.should.be.true()
        await @cluster.clean()  
