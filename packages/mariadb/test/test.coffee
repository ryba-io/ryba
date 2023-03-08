path = require 'path'
normalize = require 'masson/lib/config/normalize'

module.exports =
  tags:
      ssl: false
  env:
    images:
      centos: 'centos/7'
    networks:
      lxdbr2pub:
        'ipv4.address': '11.10.11.1/27'
        'ipv4.nat': true
        'ipv6.address': 'none'
        'dns.domain': 'nikita.local'
      lxdbr2priv:
        'ipv4.address': '11.10.10.1/27'
        'ipv4.nat': false
        'ipv6.address': 'none'
    nic:
      node1:
        eth0:
          name: 'eth0', nictype: 'bridged', parent: 'lxdbr2pub'
        eth1:
          name: 'eth1', nictype: 'bridged', parent: 'lxdbr2priv'
          'ipv4.address': '11.10.10.11', netmask: '255.255.255.0'
      node2:
        eth0:
          name: 'eth0', nictype: 'bridged', parent: 'lxdbr2pub'
        eth1:
          name: 'eth1', nictype: 'bridged', parent: 'lxdbr2priv'
          'ipv4.address': '11.10.10.12', netmask: '255.255.255.0'
  mariadb:
    default: normalize 
      clusters: 'cluster_test':
        services: 
          './src/server':
            affinity: type: 'nodes', match: 'any', values: 'node1'
            options: 
              admin_username: 'root'
              admin_password: 'secret'
              ssl: enabled: false
      nodes:
        'node1': 
          ip: '11.10.10.11'
          tags: 'type': 'node'
          cluster: 'cluster_test'
      nikita: 
        ssh: 
          username: 'nikita'
          private_key_path: path.join __dirname,".././env/assets/id_rsa"
          host: '11.10.10.11'
  config: [
    label: 'local'
  # ,
  #   label: 'remote'
  #   ssh:
  #     host: '127.0.0.1', username: process.env.USER,
  #     private_key_path: path.join __dirname,"./assets/id_rsa"
  ]
