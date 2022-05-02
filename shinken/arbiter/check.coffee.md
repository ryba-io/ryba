
# Shinken Arbiter Check

    module.exports = header: 'Shinken Arbiter Check', label_true: 'CHECKED', label_false: 'SKIPPED', handler: ->
      {arbiter} = @config.ryba.shinken

## Dryrun

      @system.execute
        header: "Dryrun"
        cmd: "shinken-arbiter -d -r -c /etc/shinken/shinken.cfg"

## TCP

      @system.execute
          header: 'TCP'
          cmd: "echo > /dev/tcp/#{@config.host}/#{arbiter.config.port}"

## HTTP

      @system.execute
        header: 'HTTP'
        cmd: "curl http://#{@config.host}:#{arbiter.config.port} | grep OK"
