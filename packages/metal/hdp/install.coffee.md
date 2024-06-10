
# HDP Repository Install

    export default header: 'HDP Install', handler: ({options}) ->

## Repository

      @tools.repo
        if: options.source?
        header: 'Repository'
        source: options.source
        target: options.target
        replace: options.replace
        update: true
