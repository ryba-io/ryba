
# MongoDB Shard Server Stop

Run the command `./bin/ryba stop -m @rybajs/storage/mongodb/shard` to stop the 
MongoDB Shard server using Ryba.

    export default header: 'MongoDB Shard Server Stop', handler: ({options}) ->

## Service

Stop the MongDB Shard server. You can also stop the server manually with one of the
following commands:

```
service mongod-shard-server stop
systemctl stop mongod-shard-server
# todo, find the stop command
```

The file storing the PID is "/var/run/mongod/mongod-shard.pid".

      @service.stop
        header: 'Stop service'
        name: 'mongod-shard-server'

## Clean Logs

Remove the "mongod-shard-server-{hostname}.log" log files if the property 
"clean_logs" is activated.

      @system.execute
        header: 'Clean Logs'
        if:  options.clean_logs
        cmd: "rm #{options.config.systemLog.path}"
        code_skipped: 1
