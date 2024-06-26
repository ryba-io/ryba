
impolrt path from 'path'
impolrt misc from '@nikitajs/core/lib/misc'

export default
  header: 'Ambari Agent Install'
  handler: ({options}) ->
    # Wait
    @call '@rybajs/ambari/server/wait', rest: options.wait_ambari_rest
    # Identities
    # By default, the "ambari-agent" package does not create any identities.
    @system.group header: 'Group', options.group
    @system.group header: 'Group Hadoop', options.hadoop_group
    @system.user header: 'User', options.user
    # Package & Repository
    # Install Ambari Agent package.
    @call headers: 'Packages', ->
      @service
        header: 'ambari-agent'
        name: 'ambari-agent'
        startup: true
      @service
        header: 'which'
        name: 'which'
      @service
        header: 'wget'
        name: 'wget'
      @service
        header: 'openssl'
        name: 'openssl'
      # leo (08/07/20) nscd coupled with sssd can be a disaster (https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/7/html/system-level_authentication_guide/usingnscd-sssd) so let's not install it for now
      # UPDATE: now managed by @rybajs/system/nscd with the righ config to work with sssd
      # @service
      #   header: 'nscd'
      #   name: 'nscd'
      #   startup: true
      #   action: 'start'
      # When starting solr in Ambari Infra, it will complain with "Please
      # install lsof as this script needs it to determine if Solr is listening
      # on port 8983."
      @service
        header: 'lsof'
        name: 'lsof'
    # Configure
    @file.ini
      header: 'Configure'
      target: "#{options.conf_dir}/ambari-agent.ini"
      content: options.config
      parse: misc.ini.parse_multi_brackets_multi_lines
      stringify: misc.ini.stringify_multi_brackets
      indent: ''
      comment: '#'
      merge: true
      uid: 0
      gid: 0
      backup: true
    @file
      header: 'Hostname Script'
      target: options.config.agent['hostname_script']
      content: """
      #!/bin/sh
      echo #{options.internal_fqdn or options.fqdn}
      """
      eof: true
      mode: 0o751
      uid: 0
      gid: 0
    # Non-Root
    @file
      if: options.config.agent['run_as_user'] isnt 'root'
      target: '/etc/sudoers.d/ambari_agent'
      content: """
      # Ambari Customizable Users
      ambari ALL=(ALL) NOPASSWD:SETENV: /bin/su hdfs *,/bin/su ambari-qa *,/bin/su ranger *,/bin/su zookeeper *,/bin/su knox *,/bin/su falcon *,/bin/su ams *, /bin/su flume *,/bin/su hbase *,/bin/su spark *,/bin/su accumulo *,/bin/su hive *,/bin/su hcat *,/bin/su kafka *,/bin/su mapred *,/bin/su oozie *,/bin/su sqoop *,/bin/su storm *,/bin/su tez *,/bin/su atlas *,/bin/su yarn *,/bin/su kms *,/bin/su activity_analyzer *,/bin/su livy *,/bin/su zeppelin *,/bin/su infra-solr *,/bin/su logsearch *
      # Ambari: Core System Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/bin/yum,/usr/bin/zypper,/usr/bin/apt-get, /bin/mkdir, /usr/bin/test, /bin/ln, /bin/ls, /bin/chown, /bin/chmod, /bin/chgrp, /bin/cp, /usr/sbin/setenforce, /usr/bin/test, /usr/bin/stat, /bin/mv, /bin/sed, /bin/rm, /bin/kill, /bin/readlink, /usr/bin/pgrep, /bin/cat, /usr/bin/unzip, /bin/tar, /usr/bin/tee, /bin/touch, /usr/bin/mysql, /sbin/service mysqld *, /usr/bin/dpkg *, /bin/rpm *, /usr/sbin/hst *
      # Ambari: Hadoop and Configuration Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/bin/hdp-select, /usr/bin/conf-select, /usr/hdp/current/hadoop-client/sbin/hadoop-daemon.sh, /usr/lib/hadoop/bin/hadoop-daemon.sh, /usr/lib/hadoop/sbin/hadoop-daemon.sh, /usr/bin/ambari-python-wrap *
      # Ambari: System User and Group Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/sbin/groupadd, /usr/sbin/groupmod, /usr/sbin/useradd, /usr/sbin/usermod
      # Ambari: Kerberos Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/bin/klist -k /etc/security/keytabs/*
      # Ambari: Knox Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/bin/python2.6 /var/lib/ambari-agent/data/tmp/validateKnoxStatus.py *, /usr/hdp/current/knox-server/bin/knoxcli.sh
      # Ambari: Ranger Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/hdp/*/ranger-usersync/setup.sh, /usr/bin/ranger-usersync-stop, /usr/bin/ranger-usersync-start, /usr/hdp/*/ranger-admin/setup.sh *, /usr/hdp/*/ranger-knox-plugin/disable-knox-plugin.sh *, /usr/hdp/*/ranger-storm-plugin/disable-storm-plugin.sh *, /usr/hdp/*/ranger-hbase-plugin/disable-hbase-plugin.sh *, /usr/hdp/*/ranger-hdfs-plugin/disable-hdfs-plugin.sh *, /usr/hdp/current/ranger-admin/ranger_credential_helper.py, /usr/hdp/current/ranger-kms/ranger_credential_helper.py, /usr/hdp/*/ranger-*/ranger_credential_helper.py
      # Ambari Infra and LogSearch Commands
      ambari ALL=(ALL) NOPASSWD:SETENV: /usr/lib/ambari-infra-solr/bin/solr *, /usr/lib/ambari-logsearch-logfeeder/run.sh *, /usr/sbin/ambari-metrics-grafana *, /usr/lib/ambari-infra-solr-client/solrCloudCli.sh *
      Defaults exempt_group = ambari
      Defaults !env_reset,env_delete-=PATH
      Defaults: ambari !requiretty
      """
      uid: 0
      gid: 0
      eof: true
    @system.remove
      header: 'Clean Sudo'
      if: options.config.agent['run_as_user'] is 'root'
      target: '/etc/sudoers.d/ambari_agent'
