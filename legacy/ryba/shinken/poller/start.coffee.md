
# Shinken Poller Start

Start the Shinken Poller service.

    export default header: 'Shinken Poller Start', handler: (options) ->

## Start Executor

Start the docker executors (normal and admin)

      @call header: 'Docker Executor', ->
        @docker.start
          container: 'poller-executor'
        @docker.exec
          container: 'poller-executor'
          cmd: "kinit #{options.krb5_principal} -kt #{options.krb5_keytab}"
          shy: true

## Start the service

      @service.start name: 'shinken-poller'
