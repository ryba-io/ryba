
# Hadoop YARN Timeline Reader Start

## Status

Check if the Timeline Server is running. The process ID is located by default
inside "/var/run/hadoop-yarn/yarn-yarn-timelineserver.pid" (TODO, check the pid file!).

    export default header: 'YARN TR Status', handler: ->
      @service.status
        name: 'hadoop-yarn-timelinereader'
