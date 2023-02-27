
# MariaDB Server Stop

    module.exports = $header: 'MariaDB Server Stop', ->
      await @service.stop 'mariadb'
