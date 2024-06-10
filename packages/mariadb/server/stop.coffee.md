
# MariaDB Server Stop

    export default header: 'MariaDB Server Stop', handler: ->
      @service.stop 'mariadb'
