
# Oozie Server Backup

    export default header: 'Oozie Server Backup', handler: ({options}) ->
      {db_admin, oozie} = @config.ryba

## Database

Note: to backup the oozie database in oozie, we must add the "hex-blob" option or
we get an error while importing data. The mysqldump command does not escape all
charactere and the xml stored inside the database create syntax issues. Here's
an example:

```bash
mysqldump -uroot -ppassword --hex-blob oozie > /data/1/oozie.sql
```

      @call header: 'Backup Database', ->
        jdbc = db.jdbc oozie.site['oozie.service.JPAService.jdbc.url']
        engines_cmd =
          mysql: """
          mysqldump \
            -u#{oozie.db.username} -p#{oozie.db.password} \
            -h#{jdbc.addresses[0].host} -P#{jdbc.addresses[0].port} \
            --hex-blob #{jdbc.database}
          """
        throw Error 'Database engine not supported' unless engines_cmd[jdbc.engine]
        @tools.backup
          name: 'oozie-db'
          cmd: engines_cmd[jdbc.engine]


## Logs

Archive the logs generated by Oozie Server.

      @tools.backup
        header: 'Backup Logs'
        name: 'oozie-logs'
        source: oozie.log_dir


## Configuration

Backup the active Oozie configuration.

      @tools.backup
        header: 'Backup Configuration'
        name: 'oozie-conf'
        source: oozie.conf_dir

## Dependencies

    db = require '@nikitajs/core/lib/misc/db'
