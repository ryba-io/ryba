
# Knox Check

Validating Service Connectivity, based on [Hortonworks Documentation][doc].

    export default header: 'Knox Check', handler: ({options}) ->
      return unless options.test.user?.name? and options.test.user?.password?
