## Check Hst Agent

Check the HST Agent host registration status

    export default header: 'HST Agent Check', handler: (options) ->
      @system.execute
        cmd: 'hst agent-status | grep registered'
