
# YARN Client Install

    export default header: 'YARN Client Install', handler: ({options}) ->

## Identities

By default, the "hadoop-yarn" package create the following entries:

```bash
cat /etc/passwd | grep yarn
yarn:x:2403:2403:Hadoop YARN User:/var/lib/hadoop-yarn:/bin/bash
cat /etc/group | grep yarn
hadoop:x:499:yarn
```

      @system.group header: 'Group', options.group
      @system.user header: 'User', options.user

## Packages Installation

      @call header: 'Packages', ->
        @service
          name: 'hadoop'
        @service
          name: 'hadoop-yarn'
        @service
          name: 'hadoop-client'

      # migration: wdavidw 170826, does a client need log and pid dirs ?
      # @call header: 'Layout', ->
      #   @system.mkdir
      #     target: "#{options.log_dir}/#{options.user.name}"
      #     uid: options.user.name
      #     gid: options.hadoop_group.name
      #     mode: 0o0755
      #     parent: true
      #   migration: wdavidw 170826, does a client need a pid dir ?
      #   pid_dir = options.pid_dir.replace '$USER', options.user.name
      #   @system.mkdir
      #     target: "#{options.pid_dir}"
      #     uid: options.user.name
      #     gid: options.hadoop_group.name
      #     mode: 0o0755
      #     parent: true

## Yarn OPTS

Inject YARN environmental properties used by the client, nodemanager and
resourcemanager.

Properties accepted by the template are: `ryba.yarn.rm_opts`   

      @file.render
        header: 'Yarn OPTS'
        target: "#{options.conf_dir}/yarn-env.sh"
        source: "#{__dirname}/../resources/yarn-env.sh.j2"
        local: true
        context:
            security_enabled: options.krb5?.realm?
            hadoop_yarn_home: options.home
            java64_home: options.java_home
            hadoop_libexec_dir: ''
            hadoop_java_io_tmpdir: "#{options.log_dir}/tmp"
            yarn_heapsize: options.heapsize
            # ryba options
            YARN_OPTS: options.opts
        uid: options.user.name
        gid: options.group.name
        mode: 0o0755
        backup: true

## Configuration

      @file.types.hfile
        header: 'Configuration'
        target: "#{options.conf_dir}/yarn-site.xml"
        source: "#{__dirname}/../../resources/core_hadoop/yarn-site.xml"
        local: true
        properties: options.yarn_site
        backup: true
        uid: options.user.name
        gid: options.group.name
