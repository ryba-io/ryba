
# Ambari Agent Start

Ambari Agent is started with the service's syntax command.

    export default header: 'Ambari Agent Start', handler: ->

# Wait for Kerberos, Zookeeper, Hadoop and Hive.
# 
#       @call once: true, '@rybajs/metal/ambari/server/wait'

Start the service

      @service.start
        name: 'ambari-agent'
