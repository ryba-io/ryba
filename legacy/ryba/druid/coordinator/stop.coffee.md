
# Druid Coordinator Stop

Run the command `./bin/ryba stop -m @rybajs/metal/druid/overlord` to stop the Druid 
Coordinator server using Ryba.

    export default header: 'Druid Coordinator Stop', handler: (options) ->

## Service

      @service.stop
        name: 'druid-coordinator'
        if_exists: '/etc/init.d/druid-coordinator'

## Clean Logs

Remove the "coordinator.log" log file if the property "clean_logs" is
activated.

      @system.execute
        header: 'Clean Logs'
        if: options.clean_logs
        cmd: "rm #{options.log_dir}/coordinator.log"
        code_skipped: 1
