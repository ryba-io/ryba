
# Spark History Server Wait

    export default header: 'Spark History Server Wait', handler: ({options}) ->

## UI Port

      @connection.wait
        header: 'UI'
        servers: options.wait.ui
