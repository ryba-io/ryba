
## Wait

    export default header: 'MongoDB Config Server Wait', handler: ({options}) ->
      @connection.wait options.tcp
