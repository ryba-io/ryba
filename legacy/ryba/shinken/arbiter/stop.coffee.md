
# Shinken Arbiter Stop

    export default header: 'Shinken Arbiter Stop', handler: (options) ->
      @service.stop name: 'shinken-arbiter'

## Clean Logs

      @call header: 'Clean Logs', if: options.clean_logs, handler: ->
        @system.execute
          cmd: 'rm /var/log/shinken/arbiterd*'
          code_skipped: 1
