
# Altas Metadata Server Check

Apache Atlas Needs the following components to be started.

    export default header: 'Atlas Check', handler: (options) ->

      @call '@rybajs/metal/atlas/wait', options.wait

      #TODO: Write Atlas Rest Api Check
