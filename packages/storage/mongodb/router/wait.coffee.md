
# MongoDB Routing Server Wait

    export default header: 'MongoDB Routing Server Wait', label_true: 'READY', handler: ({options}) ->
      @connection.wait options.tcp
