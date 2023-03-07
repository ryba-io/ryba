
module.exports =
  tags:
      ssl: true
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
