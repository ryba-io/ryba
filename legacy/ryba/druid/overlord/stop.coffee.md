
# Druid Overlord Stop

Run the command `./bin/ryba stop -m @rybajs/metal/druid/overlord` to stop the Druid 
Overlord server using Ryba.

    export default header: 'Druid Overlord Stop', handler: (options) ->

## Service

      @service.stop
        name: 'druid-overlord'
        if_exists: '/etc/init.d/druid-overlord'

## Clean Logs

Remove the "overlord.log" log file if the property "clean_logs" is
activated.

      @system.execute
        header: 'Clean Logs'
        if: options.clean_logs
        cmd: "rm #{options.log_dir}/overlord.log"
        code_skipped: 1
