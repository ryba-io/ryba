
## Configuration

    export default (service) ->
      options = service.options

## Environment

      options.env ?= {}
      options.env['TEZ_CONF_DIR'] ?= '/etc/tez/conf'
      options.env['TEZ_JARS'] ?= '/usr/hdp/current/tez-client/*:/usr/hdp/current/tez-client/lib/*'
      options.env['HADOOP_CLASSPATH'] ?= '$TEZ_CONF_DIR:$TEZ_JARS:$HADOOP_CLASSPATH'
      # Misc
      options.hostname = service.node.hostname
      options.force_check ?= false

## Kerberos

      # Kerberos HDFS Admin
      options.hdfs_krb5_user = service.deps.hadoop_core.options.hdfs.krb5_user
      # Kerberos Test Principal
      options.test_krb5_user ?= service.deps.test_user.options.krb5.user

## Configuration

      options.tez_site ?= {}
      options.tez_site['tez.lib.uris'] ?= "/hdp/apps/${hdp.version}/tez/tez.tar.gz"
      # For documentation purpose in case we HDFS_DELEGATION_TOKEN in hive queries
      # Following line: options.tez_site['tez.am.am.complete.cancel.delegation.tokens'] ?= 'false'
      # Renamed to: options.tez_site['tez.cancel.delegation.tokens.on.completion'] ?= 'false'
      # Validation
      # Java.lang.IllegalArgumentException: tez.runtime.io.sort.mb 512 should be larger than 0 and should be less than the available task memory (MB):364
      # throw Error '' options.tez_site['tez.runtime.io.sort.mb']

## Resource Allocation

      memory_per_container = 512
      rm_memory_max_mb = service.deps.yarn_rm[0].options.yarn_site['yarn.scheduler.maximum-allocation-mb']
      rm_memory_min_mb = service.deps.yarn_rm[0].options.yarn_site['yarn.scheduler.minimum-allocation-mb']
      am_memory_mb = options.tez_site['tez.am.resource.memory.mb'] or memory_per_container
      am_memory_mb = Math.min rm_memory_max_mb, am_memory_mb
      am_memory_mb = Math.max rm_memory_min_mb, am_memory_mb
      options.tez_site['tez.am.resource.memory.mb'] = am_memory_mb
      tez_memory_xmx = /-Xmx(.*?)m/.exec(options.tez_site['hive.tez.java.opts'])?[1] or Math.floor .8 * am_memory_mb
      tez_memory_xmx = Math.min rm_memory_max_mb, tez_memory_xmx
      options.tez_site['hive.tez.java.opts'] ?= "-Xmx#{tez_memory_xmx}m"

## Deprecated warning

Convert [deprecated values][dep] between HDP 2.1 and HDP 2.2.

      deprecated = {}
      deprecated['tez.am.java.opts'] = 'tez.am.launch.cmd-opts'
      deprecated['tez.am.env'] = 'tez.am.launch.env'
      deprecated['tez.am.shuffle-vertex-manager.min-src-fraction'] = 'tez.shuffle-vertex-manager.min-src-fraction'
      deprecated['tez.am.shuffle-vertex-manager.max-src-fraction'] = 'tez.shuffle-vertex-manager.max-src-fraction'
      deprecated['tez.am.shuffle-vertex-manager.enable.auto-parallel'] = 'tez.shuffle-vertex-manager.enable.auto-parallel'
      deprecated['tez.am.shuffle-vertex-manager.desired-task-input-size'] = 'tez.shuffle-vertex-manager.desired-task-input-size'
      deprecated['tez.am.shuffle-vertex-manager.min-task-parallelism'] = 'tez.shuffle-vertex-manager.min-task-parallelism'
      deprecated['tez.am.grouping.split-count'] = 'tez.grouping.split-count'
      deprecated['tez.am.grouping.by-length'] = 'tez.grouping.by-length'
      deprecated['tez.am.grouping.by-count'] = 'tez.grouping.by-count'
      deprecated['tez.am.grouping.max-size'] = 'tez.grouping.max-size'
      deprecated['tez.am.grouping.min-size'] = 'tez.grouping.min-size'
      deprecated['tez.am.grouping.rack-split-reduction'] = 'tez.grouping.rack-split-reduction'
      deprecated['tez.am.am.complete.cancel.delegation.tokens'] = 'tez.cancel.delegation.tokens.on.completion'
      deprecated['tez.am.max.task.attempts'] = 'tez.am.task.max.failed.attempts'
      deprecated['tez.generate.dag.viz'] = 'tez.generate.debug.artifacts'
      deprecated['tez.runtime.intermediate-output.key.comparator.class'] = 'tez.runtime.key.comparator.class'
      deprecated['tez.runtime.intermediate-output.key.class'] = 'tez.runtime.key.class'
      deprecated['tez.runtime.intermediate-output.value.class'] = 'tez.runtime.value.class'
      deprecated['tez.runtime.intermediate-output.should-compress'] = 'tez.runtime.compress'
      deprecated['tez.runtime.intermediate-output.compress.codec'] = 'tez.runtime.compress.codec'
      deprecated['tez.runtime.intermediate-input.key.secondary.comparator.class'] = 'tez.runtime.key.secondary.comparator.class'
      deprecated['tez.runtime.broadcast.data-via-events.enabled'] = 'tez.runtime.transfer.data-via-events.enabled'
      deprecated['tez.runtime.broadcast.data-via-events.max-size'] = 'tez.runtime.transfer.data-via-events.max-size'
      deprecated['tez.runtime.shuffle.input.buffer.percent'] = 'tez.runtime.shuffle.fetch.buffer.percent'
      deprecated['tez.runtime.task.input.buffer.percent'] = 'tez.runtime.task.input.post-merge.buffer.percent'
      deprecated['tez.runtime.job.counters.max'] = 'tez.am.counters.max.keys'
      deprecated['tez.runtime.job.counters.group.name.max'] = 'tez.am.counters.group-name.max.keys'
      deprecated['tez.runtime.job.counters.counter.name.max'] = 'tez.am.counters.name.max.keys'
      deprecated['tez.runtime.job.counters.groups.max'] = 'tez.am.counters.groups.max.keys'
      deprecated['tez.task.merge.progress.records'] = 'tez.runtime.merge.progress.records'
      deprecated['tez.runtime.metrics.session.id'] = 'tez.runtime.framework.metrics.session.id'
      deprecated['tez.task.scale.memory.additional.reservation.fraction.per-io'] = 'tez.task.scale.memory.additional-reservation.fraction.per-io'
      deprecated['tez.task.scale.memory.additional.reservation.fraction.max'] = 'tez.task.scale.memory.additional-reservation.fraction.max'
      deprecated['tez.task.initial.memory.scale.ratios'] = 'tez.task.scale.memory.ratios'
      deprecated['tez.resource.calculator.process-tree.class'] = 'tez.task.resource.calculator.process-tree.class'
      for previous, current of deprecated
        continue unless options.tez_site[previous]
        options.tez_site[current] = options.tez_site[previous]
        console.log "Deprecated property '#{previous}' [WARN]"

      if service.deps.yarn_ts?.length?
        if service.deps.yarn_ts[0].options.yarn_site['yarn.timeline-service.version'] is '1.5'
          options.tez_site['tez.history.logging.service.class'] ?= 'org.apache.tez.dag.history.logging.ats.ATSV15HistoryLoggingService'
        else
          options.tez_site['tez.history.logging.service.class'] ?= 'org.apache.tez.dag.history.logging.ats.ATSHistoryLoggingService'
      else
        options.tez_site['tez.history.logging.service.class'] ?= 'org.apache.tez.dag.history.logging.proto.ProtoHistoryLoggingService'

## Tez Ports

Enrich the Yarn NodeManager with additionnal IPTables rules.

      # Range of ports that the AM can use when binding for client connections
      options.tez_site['tez.am.client.am.port-range'] ?= '34816-36864'
      for srv in service.deps.yarn_nm
        srv.options.iptables_rules.push { chain: 'INPUT', jump: 'ACCEPT', dport: options.tez_site['tez.am.client.am.port-range'].replace('-',':'), protocol: 'tcp', state: 'NEW', comment: "Tez AM Range" }

## UI

      options.ui ?= {}
      options.ui.enabled ?= !!service.deps.httpd
      if options.ui.enabled
        options.ui.env ?= {}
        options.ui.env.hosts ?= {}
        unless options.tez_site['tez.tez-ui.history-url.base'] and options.ui.html_path
          unless service.deps.httpd
            throw 'Install masson/commons/httpd on ' + service.node.fqdn + ' or specify tez_site[\'tez.tez-ui.history-url.base\'] and ui.html_path if ui.enabled'
          options.tez_site['tez.tez-ui.history-url.base'] ?= "http://#{service.node.fqdn}/tez-ui"
          options.ui.html_path ?= "#{service.deps.httpd.options.user.home}/tez-ui"
        id = if service.deps.yarn_rm[0].options.yarn_site['yarn.resourcemanager.ha.enabled'] is 'true' then ".#{service.deps.yarn_rm[0].options.yarn_site['yarn.resourcemanager.ha.id']}" else ''
        if service.deps.yarn_ts?.length?
          options.ui.env.hosts.timeline ?= if service.deps.yarn_ts[0].options.yarn_site['yarn.http.policy'] is 'HTTP_ONLY'
          then "http://" + service.deps.yarn_ts[0].options.yarn_site['yarn.timeline-service.webapp.address']
          else "https://"+ service.deps.yarn_ts[0].options.yarn_site['yarn.timeline-service.webapp.https.address']
        else
          options.ui.env.hosts.timeline ?= if service.deps.yarn_tr[0].options.yarn_site['yarn.http.policy'] is 'HTTP_ONLY'
          then "http://" + service.deps.yarn_tr[0].options.yarn_site['yarn.timeline-service.webapp.address']
          else "https://"+ service.deps.yarn_tr[0].options.yarn_site['yarn.timeline-service.webapp.https.address']
        options.ui.env.hosts.rm ?= if service.deps.yarn_rm[0].options.yarn_site['yarn.http.policy'] is 'HTTP_ONLY'
        then "http://" + service.deps.yarn_rm[0].options.yarn_site["yarn.resourcemanager.webapp.address#{id}"]
        else "https://"+ service.deps.yarn_rm[0].options.yarn_site["yarn.resourcemanager.webapp.https.address#{id}"]
        ## Tez Site when UI is enabled
        options.tez_site['tez.runtime.convert.user-payload.to.history-text'] ?= 'true'

[tez]: http://tez.apache.org/
[instructions]: (http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.2.0/HDP_Man_Install_v22/index.html#Item1.8.4)
[dep]: http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.2.4/bk_upgrading_hdp_manually/content/start-tez-21.html
