
# MariaDB Server Start

    export default header: 'MariaDB Server Start', handler: ->
      @service.start 'mariadb'
