
## Configure Kafka Broker

Example:

```json
{
  "ryba": {
    "kafka": {
      "broker": {
        "heapsize": 1024
      }
    }
  }
}
```

    export default (service) ->
      options = service.options
      
## Kerberos

      options.krb5 ?= {}
      options.krb5.realm ?= service.deps.krb5_client.options.etc_krb5_conf?.libdefaults?.default_realm
      throw Error 'Required Options: "realm"' unless options.krb5.realm
      options.krb5.admin ?= service.deps.krb5_client.options.admin[options.krb5.realm]

## Identities

      # Group
      options.group = name: options.group if typeof options.group is 'string'
      options.group ?= {}
      options.group.name ?= 'kafka'
      options.group.system ?= true
      # User
      options.user ?= {}
      options.user = name: options.user if typeof options.user is 'string'
      options.user.name ?= options.group.name
      options.user.gid = options.group.name
      options.user.system ?= true
      options.user.comment ?= 'Kafka User'
      options.user.home = "/var/lib/#{options.user.name}"
      options.user.limits ?= {}
      options.user.limits.nofile ?= 64000
      options.user.limits.nproc ?= 32000
      # Admin
      options.admin ?= {}
      options.admin.principal ?= "#{options.user.name}@#{options.krb5.realm}"
      throw Error "Required Option: admin.password" unless options.admin.password
      #list of kafka superusers
      # match = /^(.+?)[@\/]/.exec options.admin.principal
      # throw Error 'Invalid kafka.broker.admin.principal' unless match
      # options.superusers ?= [match[0]]
      # throw Error 'Kafka admin_principal must be in kafka superusers' unless match[0] in options.superusers
      options.superusers ?= [options.admin.principal.split('@')[0].split('/')[0]]

## Environment

      # Layout
      options.conf_dir ?= '/etc/kafka-broker/conf'
      options.log_dir ?= '/var/log/kafka'
      options.run_dir ?= '/var/run/kafka'
      # Env and Java
      options.heapsize ?= '1024'
      options.env ?= {}
      # A more agressive configuration for production is provided here:
      # http://docs.confluent.io/1.0.1/kafka-rest/docs/deployment.html#jvm
      options.env['KAFKA_HEAP_OPTS'] ?= "-Xmx#{options.heapsize}m -Xms#{options.heapsize}m"
      # Avoid console verbose ouput in a non-rotated kafka.out file
      # options.env['KAFKA_LOG4J_OPTS'] ?= "-Dlog4j.configuration=file:$base_dir/../config/log4j.properties -Dkafka.root.logger=INFO, kafkaAppender"
      options.env['KAFKA_LOG4J_OPTS'] ?= "-Dlog4j.configuration=file:#{options.conf_dir}/log4j.properties"
      options.env['KAFKA_GC_LOG_OPTS'] ?= "-Xloggc:$LOG_DIR/$GC_LOG_FILE_NAME -verbose:gc -XX:+PrintGCDetails -XX:+PrintGCDateStamps -XX:+PrintGCTimeStamps "
      # Misc
      options.iptables ?= service.deps.iptables and service.deps.iptables.options.action is 'start'

## ZooKeeper Quorun

      options.zookeeper_quorum ?= for srv in service.deps.zookeeper_server
        continue unless srv.options.config['peerType'] is 'participant'
        "#{srv.node.fqdn}:#{srv.options.config['clientPort']}"

## Configuration

      options.config ?= {}

      options.config['log.dirs'] ?= '/var/kafka'  # Comma-separated, default is "/tmp/kafka-logs"
      options.config['log.dirs'] = options.config['log.dirs'].join ',' if Array.isArray options.config['log.dirs']
      options.config['zookeeper.connect'] ?= options.zookeeper_quorum
      options.config['log.retention.hours'] ?= '168'
      options.config['delete.topic.enable'] ?= 'true'
      options.config['zookeeper.set.acl'] ?= 'true'
      options.config['super.users'] ?= options.superusers.map( (user) -> "User:#{user}").join(',')
      options.config['num.partitions'] ?= service.instances.length # Default number of log partitions per topic, default is "2"
      options.config['auto.create.topics.enable'] ?= 'false'
      for instance, i in service.instances
        options.config['broker.id'] ?= "#{i}" if instance.node.fqdn is service.node.fqdn

## Metrics

      options.metrics = merge service.deps.metrics?.options, options.metrics
      options.metrics.sinks ?= {}
      options.metrics.sinks.file_enabled ?= true
      options.metrics.sinks.ganglia_enabled ?= false
      options.metrics.sinks.graphite_enabled ?= false
      # Graphite Sink
      if options.metrics.sinks.graphite_enabled
        throw Error 'Missing remote_host ryba.kafka.broker.metrics.sinks.graphite.config.server_host' unless options.metrics.sinks.graphite.config?.server_host?
        throw Error 'Missing remote_port ryba.kafka.broker.metrics.sinks.graphite.config.server_port' unless options.metrics.sinks.graphite.config?.server_port?
        options.config['kafka.metrics.reporters'] ?= 'com.criteo.kafka.KafkaGraphiteMetricsReporter'
        options.config['kafka.graphite.metrics.reporter.enabled'] ?= 'true'
        options.config['kafka.graphite.metrics.host'] ?= options.metrics.sinks.graphite.config.server_host
        options.config['kafka.graphite.metrics.port'] ?= options.metrics.sinks.graphite.config.server_port
        options.config['kafka.graphite.metrics.group'] ?= "#{options.metrics.sinks.graphite.config.metrics_prefix}.#{service.node.fqdn}"

# Log4J

      options.log4j = merge service.deps.log4j?.options, options.log4j

      options.log4j.properties ?= {}
      options.log4j.properties['log4j.appender.stdout'] ?= 'org.apache.log4j.ConsoleAppender'
      options.log4j.properties['log4j.appender.stdout.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.stdout.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.properties['log4j.appender.kafkaAppender'] ?= 'org.apache.log4j.RollingFileAppender'
      options.log4j.properties['log4j.appender.kafkaAppender.MaxFileSize'] ?= '100MB'
      options.log4j.properties['log4j.appender.kafkaAppender.MaxBackupIndex'] ?= '10'
      options.log4j.properties['log4j.appender.kafkaAppender.File'] ?= '${kafka.logs.dir}/server.log'
      options.log4j.properties['log4j.appender.kafkaAppender.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.kafkaAppender.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.properties['log4j.appender.stateChangeAppender'] ?= 'org.apache.log4j.RollingFileAppender'
      options.log4j.properties['log4j.appender.stateChangeAppender.MaxFileSize'] ?= '100MB'
      options.log4j.properties['log4j.appender.stateChangeAppender.MaxBackupIndex'] ?= '1'
      options.log4j.properties['log4j.appender.stateChangeAppender.File'] ?= '${kafka.logs.dir}/state-change.log'
      options.log4j.properties['log4j.appender.stateChangeAppender.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.stateChangeAppender.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.properties['log4j.appender.requestAppender'] ?= 'org.apache.log4j.RollingFileAppender'
      options.log4j.properties['log4j.appender.requestAppender.MaxFileSize'] ?= '100MB'
      options.log4j.properties['log4j.appender.requestAppender.MaxBackupIndex'] ?= '1'
      options.log4j.properties['log4j.appender.requestAppender.File'] ?= '${kafka.logs.dir}/kafka-request.log'
      options.log4j.properties['log4j.appender.requestAppender.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.requestAppender.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.properties['log4j.appender.cleanerAppender'] ?= 'org.apache.log4j.RollingFileAppender'
      options.log4j.properties['log4j.appender.cleanerAppender.MaxFileSize'] ?= '100MB'
      options.log4j.properties['log4j.appender.cleanerAppender.MaxBackupIndex'] ?= '1'
      options.log4j.properties['log4j.appender.cleanerAppender.File'] ?= '${kafka.logs.dir}/log-cleaner.log'
      options.log4j.properties['log4j.appender.cleanerAppender.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.cleanerAppender.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.properties['log4j.appender.controllerAppender'] ?= 'org.apache.log4j.RollingFileAppender'
      options.log4j.properties['log4j.appender.controllerAppender.MaxFileSize'] ?= '100MB'
      options.log4j.properties['log4j.appender.controllerAppender.MaxBackupIndex'] ?= '1'
      options.log4j.properties['log4j.appender.controllerAppender.File'] ?= '${kafka.logs.dir}/controller.log'
      options.log4j.properties['log4j.appender.controllerAppender.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.controllerAppender.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.properties['log4j.appender.authorizerAppender'] ?= 'org.apache.log4j.RollingFileAppender'
      options.log4j.properties['log4j.appender.authorizerAppender.MaxFileSize'] ?= '100MB'
      options.log4j.properties['log4j.appender.authorizerAppender.MaxBackupIndex'] ?= '1'
      options.log4j.properties['log4j.appender.authorizerAppender.File'] ?= '${kafka.logs.dir}/kafka-authorizer.log'
      options.log4j.properties['log4j.appender.authorizerAppender.layout'] ?= 'org.apache.log4j.PatternLayout'
      options.log4j.properties['log4j.appender.authorizerAppender.layout.ConversionPattern'] ?= '[%d] %p %m (%c)%n'
      options.log4j.extra_appender = ''
      if options.log4j.remote_host and options.log4j.remote_port
        options.log4j.extra_appender = ',socketAppender'
        options.log4j.properties['log4j.appender.socketAppender'] ?= 'org.apache.log4j.net.SocketAppender'
        options.log4j.properties['log4j.appender.socketAppender.Application'] ?= 'kafka'
        options.log4j.properties['log4j.appender.socketAppender.RemoteHost'] ?= options.log4j.remote_host
        options.log4j.properties['log4j.appender.socketAppender.Port'] ?= options.log4j.remote_port
        options.log4j.properties['log4j.appender.socketAppender.ReconnectionDelay'] ?= '10000'
      #options.log4j.properties['log4j.logger.kafka.producer.async.DefaultEventHandler'] ?= 'DEBUG, kafkaAppender' + options.log4j.extra_appender
      #options.log4j.properties['log4j.logger.kafka.client.ClientUtils'] ?= 'DEBUG, kafkaAppender' + options.log4j.extra_appender
      #options.log4j.properties['log4j.logger.kafka.perf'] ?= 'DEBUG, kafkaAppender' + ' socketAppender' + options.log4j.extra_appender
      #options.log4j.properties['log4j.logger.kafka.perf.ProducerPerformance$ProducerThread'] ?= 'DEBUG, kafkaAppender' + options.log4j.extra_appender
      #options.log4j.properties['log4j.logger.org.I0Itec.zkclient.ZkClient'] ?= 'DEBUG'
      #options.log4j.properties['log4j.logger.kafka.network.Processor'] ?= 'TRACE, requestAppender' + options.log4j.extra_appender
      #options.log4j.properties['log4j.logger.kafka.server.KafkaApis'] ?= 'TRACE, requestAppender' + options.log4j.extra_appender
      #options.log4j.properties['log4j.additivity.kafka.server.KafkaApis'] ?= 'false'
      options.log4j.properties['log4j.rootLogger'] ?= 'INFO, kafkaAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.logger.kafka'] ?= 'INFO, kafkaAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.kafka'] ?= 'false'
      options.log4j.properties['log4j.logger.kafka.network.RequestChannel$'] ?= 'WARN, requestAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.kafka.network.RequestChannel$'] ?= 'false'
      options.log4j.properties['log4j.logger.kafka.request.logger'] ?= 'WARN, requestAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.kafka.request.logger'] ?= 'false'
      options.log4j.properties['log4j.logger.kafka.controller'] ?= 'TRACE, controllerAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.kafka.controller'] ?= 'false'
      options.log4j.properties['log4j.logger.kafka.log.LogCleaner'] ?= 'INFO, cleanerAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.kafka.log.LogCleaner'] ?= 'false'
      options.log4j.properties['log4j.logger.state.change.logger'] ?= 'TRACE, stateChangeAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.state.change.logger'] ?= 'false'
      options.log4j.properties['log4j.logger.kafka.authorizer.logger'] ?= 'WARN, authorizerAppender' + options.log4j.extra_appender
      options.log4j.properties['log4j.additivity.kafka.authorizer.logger'] ?= 'false'
      # Push user and group configuration to consumer and producer
      # for csm_ctx in ctx.contexts ['@rybajs/metal/kafka/consumer', '@rybajs/metal/kafka/producer']
      #   csm_ctx.config.ryba ?= {}
      #   csm_ctx.config.ryba.kafka ?= {}
      #   csm_ctx.config.ryba.kafka.user ?= kafka.user
      #   csm_ctx.config.ryba.kafka.group ?= kafka.group

## Kafka Broker Protocols

Sarting from 0.9, kafka broker supports multiple secured and un-secured protocols when
broadcasting messages for broker/broker and client/broker communications.
They are PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL.
By default it set at least to SSL for broker/broker and client/broker.
For broker/client communication all protocols are supported.
For broker/broker communication we allow only SSL or SASL_SSL.
Needed protocols can be set at cluster config level.

Example only PLAINTEXT:
{
  "ryba": {
    "kafka": {
      "broker": {
        "protocols" : "PLAINTEXT"
      }
    }
  }
}
Example PLAINTEXT and SSL:
{
  "ryba": {
    "kafka": {
      "broker": {
        "protocols" : ["PLAINTEXT","SSL"]
      }
    }
  }
}

      options.protocols ?= if service.deps.hadoop_core.options.core_site['hadoop.security.authentication'] is 'kerberos' then ['SASL_SSL'] else ['SSL']
      return Error 'No protocol specified' unless options.protocols.length > 0
      options.ports ?= {}
      options.ports['PLAINTEXT'] ?= '9092'
      options.ports['SSL'] ?= '9093'
      options.ports['SASL_PLAINTEXT'] ?= '9094'
      options.ports['SASL_SSL'] ?= '9096'

## Security protocol used to communicate between brokers

Valid values are: PLAINTEXT, SSL, SASL_PLAINTEXT, SASL_SSL.

      options.config['security.inter.broker.protocol'] ?= if service.deps.hadoop_core.options.core_site['hadoop.security.authentication'] is 'kerberos'
      then ['SASL_SSL']
      else ['SSL']

## Security SSL

      options.ssl = merge service.deps.ssl?.options, options.ssl
      options.config['ssl.keystore.location'] ?= "#{options.conf_dir}/keystore"
      throw Error "Required Option: options.config['ssl.keystore.password']" unless options.config['ssl.keystore.password']
      options.config['ssl.key.password'] ?= options.config['ssl.keystore.password']
      options.config['ssl.truststore.location'] ?= "#{options.conf_dir}/truststore"
      throw Error "Required Option: options.config['ssl.truststore.passwor']" unless options.config['ssl.truststore.password']

## Security Kerberos & ACL

      if options.config['zookeeper.set.acl'] is 'true'
        options.kerberos ?= {}
        options.kerberos['principal'] ?= "#{options.user.name}/#{service.node.fqdn}@#{options.krb5.realm}"
        options.kerberos['keyTab'] ?= '/etc/security/keytabs/kafka.service.keytab'
        match = /^(.+?)[@\/]/.exec options.kerberos['principal']
        options.config['sasl.kerberos.service.name'] = "#{match[1]}"
        # set to true to be able to use 9092 if PLAINTEXT only mode is enabled
        options.config['allow.everyone.if.no.acl.found'] ?= 'false'
        options.config['authorizer.class.name'] ?= 'kafka.security.auth.SimpleAclAuthorizer'
        options.env['KAFKA_KERBEROS_PARAMS'] ?= "-Djava.security.auth.login.config=#{options.conf_dir}/kafka-server.jaas"

## Brokers internal communication

      if options.config['zookeeper.set.acl'] is 'true'
        options.config['replication.security.protocol'] ?= 'SASL_SSL'
      else
        options.config['replication.security.protocol'] ?= 'SSL'
      # Validation
      for prot in options.protocols
        throw Error 'ACL must be activated' if prot.indexOf('SASL') > -1 and options.config['zookeeper.set.acl'] isnt 'true'

## Listeners Protocols

      # HDP 2.5.0
      throw Error 'security.inter.broker.protocol must be a protocol in the configured set of advertised.listeners' unless options.config['replication.security.protocol'] in options.protocols
      options.config['listeners'] ?= options.protocols
      .map (protocol) -> "#{protocol}://#{service.node.fqdn}:#{options.ports[protocol]}"
      .join ','

## Wait

      options.wait_krb5_client = service.deps.krb5_client.options.wait
      options.wait_zookeeper_server = service.deps.zookeeper_server[0].options.wait
      options.wait = {}
      # options.wait.brokers = for srv in service.deps.kafka_broker
      #   for protocol in options.protocols
      #     host: srv.node.fqdn
      #     port: options.ports[protocol]
      for protocol in options.protocols
        options.wait[protocol] = for srv in service.deps.kafka_broker
          host: srv.node.fqdn
          port: options.ports[protocol]

## Dependencies

    {merge} = require 'mixme'

[kafka-security]:(http://kafka.apache.org/documentation.html#security)
[hdp-security-kafka]:(https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.3.4/bk_Security_Guide/content/ch_wire-kafka.html)
