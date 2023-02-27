
# MariaDB Server Start

    module.exports = $header: 'MariaDB Server Start', ->
      await @service.start 'mariadb'
