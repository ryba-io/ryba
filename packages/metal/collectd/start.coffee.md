
# Collectd Start
Uses rpm's package default systemd scripts.

    export default header: 'Collectd Start', handler: (options) ->

## Packages

      @service.start name: 'collectd'
