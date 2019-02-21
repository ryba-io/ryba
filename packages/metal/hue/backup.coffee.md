
# Hue backup

    module.exports = header: 'Hue Backup', handler: ->
      {hue} = @config.ryba

## Database

      @call header: 'Database', ->
        {engine, host, port, user, password, name} = @config.ryba.hue.ini.desktop.database
        engines_cmd =
          mysql: "mysqldump -u#{database.user} -p#{database.password} -h#{database.host} -P#{database.port} #{database.name}"
        throw Error 'Database engine not supported' unless engines_cmd[database.engine]
        @tools.backup
          name: 'db'
          cmd: engines_cmd[engine]
          target: "/var/backups/hue/"
          interval: month: 1
          retention: count: 2

## Logs

Archive the logs generated by Hue.

      @call header: 'Logs', ->
        @tools.backup
          name: 'logs'
          source: hue.log_dir
          target: "/var/backups/hue/"
          interval: month: 1
          retention: count: 2

## Configuration

Backup the active Hue configuration.

      @call header: 'Configuration', ->
        @tools.backup
          name: 'conf'
          source: hue.conf_dir
          target: "/var/backups/hue/"
          interval: month: 1
          retention: count: 2