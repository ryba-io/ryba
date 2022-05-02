
# Poller Executor Build

    module.exports = header: 'Shinken Poller Prepare', handler: ->
      {shinken} = @config.ryba
      if @contexts('ryba/shinken/poller')[0].config.host is @config.host

## Build Container

        @file.render
          header: 'Render Dockerfile'
          target: "#{@config.nikita.cache_dir or '.'}/build/Dockerfile"
          source: "#{__dirname}/resources/Dockerfile.j2"
          local: true
          context: @config.ryba
        @file
          header: 'Write Java Profile'
          target: "#{@config.nikita.cache_dir or '.'}/build/java.sh"
          content: """
          export JAVA_HOME=/usr/java/default
          export PATH=/usr/java/default/bin:$PATH
          """
        @file
          header: 'Write RSA Private Key'
          target: "#{@config.nikita.cache_dir or '.'}/build/id_rsa"
          content: @config.ssh.private_key
        @file
          header: 'Write RSA Public Key'
          target: "#{@config.nikita.cache_dir or '.'}/build/id_rsa.pub"
          content: @config.ssh.public_key
        @docker.build
          header: 'Build Container'
          image: 'ryba/shinken-poller-executor'
          file: "#{@config.nikita.cache_dir or '.'}/build/Dockerfile"
          cwd: shinken.poller.executor.build_dir

## Save image

        @docker.save
          header: 'Save Container'
          image: 'ryba/shinken-poller-executor'
          target: "#{@config.nikita.cache_dir or '.'}/shinken-poller-executor.tar"
