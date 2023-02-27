
# MariaDB Server Start

    module.exports = $header: 'MariaDB Server Start', handler: ->
      await @service.start 'mariadb'
