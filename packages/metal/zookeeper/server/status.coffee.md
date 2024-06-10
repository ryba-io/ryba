
# Zookeeper Server Status

Check if the ZooKeeper server is running. The process ID is located by default
inside "/var/run/zookeeper/zookeeper_server.pid".

    export default header: 'ZooKeeper Server Status', handler: ({options}) ->
      @service.status name: 'zookeeper-server'
