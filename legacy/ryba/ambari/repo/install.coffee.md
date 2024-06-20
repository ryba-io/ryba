
# Ambari Repo Install

    export default header: 'Ambari Repo Install', handler: ({options}) ->
      @tools.repo
        if: options.source?
        header: 'Repository'
        source: options.source
        target: options.target
        replace: options.replace
        update: true
