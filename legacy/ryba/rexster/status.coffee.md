
# Rexster Status

Run the command `./bin/ryba status -m @rybajs/metal/titan/rexster` to retrieve the status
of the Titan server using Ryba.

    export default header: 'Rexster Status', handler: ->
      @system.execute
        cmd: "ps aux | grep 'com.tinkerpop.rexster.Application'"
        code_skipped: 1
