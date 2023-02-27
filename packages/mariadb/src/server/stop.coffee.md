
# MariaDB Server Stop

    module.exports = $header: 'MariaDB Server Stop', handler: ->
      await @service.stop 'mariadb'
