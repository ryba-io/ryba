
# Hue Status

Check if hue_server container is running

    export default header: 'Hue Docker Status', handler: (options) ->

      @docker.status  container: options.container
