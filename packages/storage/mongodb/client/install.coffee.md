
# MongoDB Client Install

    export default header: 'MongoDB Client Packages', handler: ({options}) ->
      @service name: 'mongodb-org-shell'
      @service name: 'mongodb-org-tools'
