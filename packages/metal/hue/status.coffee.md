
# Hue Status

Check if the Hue server is running. The process ID is located by default
inside "/var/run/hue/supervisor.pid".

    export default header: 'Hue Status', handler: ->
      @service.status
        name: 'hue'
