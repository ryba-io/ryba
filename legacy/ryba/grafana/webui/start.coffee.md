
# Grafana Prepare

    export default header: 'Grafana Start', handler: ({options}) ->

## Wait for database to listen

      @call '@rybajs/metal/commons/db_admin/wait', once: true, options.wait_db_admin

## Service Start

      @service.start 'grafana-webui'
