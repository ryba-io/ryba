

export default header: 'Hue Stop', handler: ({config}) ->
  @service.stop
    header: 'Stop service'
    name: 'hue'
  @system.execute
    header: 'Clean Logs'
    if: -> config.clean_logs
    cmd: "rm #{config.log_dir}/*"
    code_skipped: 1
