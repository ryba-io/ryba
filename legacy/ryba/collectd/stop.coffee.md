
# Collectd Stop
Uses rpm's package default systemd scripts.

    export default header: 'Collectd Stop', handler: (options) ->

## Packages

      @service.stop 'collectd'
