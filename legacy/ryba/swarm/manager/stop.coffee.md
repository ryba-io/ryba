
# Stop Docker Swarm Manager Container

Stop the docker container using docker stop command.

    export default header: 'Swarm Manager Stop', handler: (options) ->
      @docker.stop
        docker: options.docker
        container: options.name
