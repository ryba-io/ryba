path = require 'path'
registry = require '@nikitajs/core/lib/registry'
cert_script = path.join(__dirname, './assets/cert/generate')
{env, tags} = require '../test/test.coffee'
{images, networks, nic} = env

cluster =
  networks: networks
  containers:
    nikita:
      image: "images:#{images.centos}"
      disk:
        nikitadir:
          path: '/ryba'
          source: process.env['NIKITA_HOME'] or path.join(__dirname, '../../../../')
      ssh: enabled: true
    node1:
      image: "images:#{images.centos}"
      nic: nic.node1
      ssh: enabled: true
      user:
        nikita: 
          sudo: true
          authorized_keys: path.join(__dirname,"./assets/id_rsa.pub")
    node2:
      image: "images:#{images.centos}"
      nic: nic.node2
      ssh: enabled: true
      user:
        nikita:
          sudo: true
          authorized_keys: path.join(__dirname,"./assets/id_rsa.pub")
  prevision: ({ config }) ->
    await @tools.ssh.keygen
      $header: 'SSH key'
      target: path.join(__dirname,"./assets/id_rsa")
      bits: 2048
      key_format: 'PEM'
      comment: 'nikita'
    return unless tags.ssl
    await @execute
      $header: 'Create Certificates'
      command: """
      cd ./env/assets/cert
      sh #{cert_script} cacert
      sh #{cert_script} cert server
      sh #{cert_script} cert client
      """
  provision_container: ({ config }) ->
    await @execute
      $header: 'Keys permissions'
      command: """
      cd #{path.join(__dirname,"./assets")}
      chmod 777 id_rsa id_rsa.pub
      """
    await @lxc.exec
      $header: 'Node.js'
      container: config.container
      command: '''
      if command -v node ; then exit 42; fi
      curl -sS -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
      . ~/.bashrc
      nvm install 16
      '''
      trap: true
      code: [0, 42]
    # Configuration required for node_1 and node_2 only:
    await @call ->
      return if config.container is 'nikita'
      await @lxc.file.push
          $header: 'Configure ip address eth1 nic'
          container: config.container
          target: '/etc/sysconfig/network-scripts/ifcfg-eth1'
          content: """
          DEVICE=eth1
          BOOTPROTO=none
          ONBOOT=yes
          IPADDR=#{config.nic.eth1['ipv4.address']}
          """
      await @lxc.exec
          $header: 'Restart network'
          container: config.container
          command: """
          systemctl restart network
          """
      await @lxc.file.push
          $header: 'User Private Key'
          container: config.container
          gid: 'nikita'
          uid: 'nikita'
          source: path.join(__dirname,"./assets/id_rsa")
          target: '/home/nikita/.ssh/id_rsa'
      await @lxc.exec
          $header: 'Root SSH dir'
          container: config.container
          command: 'mkdir -p /root/.ssh && chmod 700 /root/.ssh'
      await @lxc.file.push
          $header: 'Root SSH Private Key'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/id_rsa")
          target: '/root/.ssh/id_rsa'
    # SSL configuration
    return unless tags.ssl
    await @call ->
      $header: 'SSL configuration'
      await @call ->
        $header: 'Server certificates'
        return if config.container isnt 'node1'
        await @lxc.file.push
          $header: 'Copy server cert'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/cert/server.cert.pem")
          target: '/etc/ssl/server.cert.pem'
        await @lxc.file.push
          $header: 'Copy server key'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/cert/server.key.pem")
          target: '/etc/ssl/server.key.pem'
        await @lxc.file.push
          $header: 'Copy server ca-cert'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/cert/ca.cert.pem")
          target: '/etc/ssl/ca.cert.pem'
      await @call ->
        $header: 'Client certificates'
        return if config.container isnt 'node2'
        await @lxc.file.push
          $header: 'Copy client cert'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/cert/client.cert.pem")
          target: '/etc/ssl/client.cert.pem'
        await @lxc.file.push
          $header: 'Copy client key'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/cert/client.key.pem")
          target: '/etc/ssl/client.key.pem'
        await @lxc.file.push
          $header: 'Copy client ca-cert'
          container: config.container
          gid: 'root'
          uid: 'root'
          source: path.join(__dirname,"./assets/cert/ca.cert.pem")
          target: '/etc/ssl/ca.cert.pem'

registry.register ['cluster', 'clean'], ->
  # Delete test cluster
  await @lxc.cluster.delete {...cluster, force: true}
  await @execute
    $header: 'Remove ssh keys and certificates'
    command: """
    cd #{path.join(__dirname,"./assets")}
    rm -rf id_rsa id_rsa.pub
    cd cert
    rm -rf ca.cert.pem ca.key.pem ca.seq client.cert.pem client.key.pem server.cert.pem server.key.pem
    """
registry.register ['cluster', 'create'], ->
  # Create test cluster
  await @lxc.cluster {...cluster }
