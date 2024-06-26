
# Hadoop HDFS NameNode Check

Check the health of the NameNode(s).

In HA mode, we need to ensure both NameNodes are installed before testing SSH
Fencing. Otherwise, a race condition may occur if a host attempt to connect
through SSH over another one where the public key isn't yet deployed.

    export default header: 'HDFS NN Check', handler: ({options}) ->

## Wait

Wait for the HDFS NameNode to be started.

      # TODO: replaced wait with assertion
      @call once: true, '@rybajs/metal/hadoop/hdfs_nn/wait', options.wait

## Check HTTP

      protocol = if options.hdfs_site['dfs.http.policy'] is 'HTTP_ONLY' then 'http' else 'https'
      nameservice = if options.nameservice then ".#{options.nameservice}" else ''
      shortname = if options.nameservice then ".#{options.hostname}" else ''
      address = options.hdfs_site["dfs.namenode.#{protocol}-address#{nameservice}#{shortname}"]
      [_, port] = address.split ':'
      securityEnabled = protocol is 'https'
      @system.execute
        retry: 2
        header: 'HTTP'
        cmd: mkcmd.hdfs options.hdfs_krb5_user, "curl --negotiate -k -u : #{protocol}://#{options.fqdn}:#{port}/jmx?qry=Hadoop:service=NameNode,name=NameNodeStatus"
      , (err, obj) ->
        throw err if err
        data = JSON.parse obj.stdout
        # After HDP2.2, the response needs some time before returning any beans
        throw Error "Invalid Response" unless Array.isArray data?.beans
        # throw Error "Invalid Response" unless /^Hadoop:service=NameNode,name=NameNodeStatus$/.test data?.beans[0]?.name
        # throw Error "WARNING: Invalid security (#{data.beans[0].SecurityEnabled}, instead of #{securityEnabled}" unless data.beans[0].SecurityEnabled is securityEnabled

## Check Health

Connect to the provided NameNode to check its health. The NameNode is capable of
performing some diagnostics on itself, including checking if internal services
are running as expected. This command will return 0 if the NameNode is healthy,
non-zero otherwise. One might use this command for monitoring purposes.

Checkhealth return result is not completely implemented
See More http://hadoop.apache.org/docs/r2.0.2-alpha/hadoop-yarn/hadoop-yarn-site/HDFSHighAvailability.html#Administrative_commands

      @system.execute
        header: 'HA Health'
        if: -> options.nameservice
        cmd: mkcmd.hdfs options.hdfs_krb5_user, "hdfs --config '#{options.conf_dir}' haadmin -checkHealth #{options.hostname}"

## Check FSCK

Check for various inconsistencies on the overall filesystem. Use the command
`hdfs fsck -list-corruptfileblocks` to list the corrupted blocks.

Corrupted blocks for removal can be found with the command: 
`hdfs fsck / | egrep -v '^\.+$' | grep -v replica | grep -v Replica`
Additionnal information may be found on the [CentOS HowTos site][corblk].

[corblk]: http://centoshowtos.org/hadoop/fix-corrupt-blocks-on-hdfs/

      check_hdfs_fsck = if options.check_hdfs_fsck? then !!options.check_hdfs_fsck else true
      @system.execute
        header: 'FSCK'
        retry: 3
        wait: 60000
        cmd: mkcmd.hdfs options.hdfs_krb5_user, "exec 5>&1; hdfs --config #{options.conf_dir} fsck / | tee /dev/fd/5 | tail -1 | grep HEALTHY 1>/dev/null"
        if: options.force_check or check_hdfs_fsck

## Check HDFS

Attemp to place a file inside HDFS. the file "/etc/passwd" will be placed at
"/user/{test\_user}/{fqnd}\_dn".

      @system.execute
        header: 'HDFS'
        cmd: mkcmd.test options.test_krb5_user, """
        if hdfs --config '#{options.conf_dir}' dfs -test -f /user/#{options.test.user.name}/#{options.hostname}-nn; then exit 2; fi
        echo 'Upload file to HDFS'
        hdfs --config '#{options.conf_dir}' dfs -put /etc/passwd /user/#{options.test.user.name}/#{options.hostname}-nn
        """
        code_skipped: 2

## Check WebHDFS

Check the Kerberos SPNEGO and the Hadoop delegation token. Will only be
executed if the file "/user/{test\_user}/{host}\_webhdfs" generated by this action
is not present on HDFS.

Read [Delegation Tokens in Hadoop Security](http://www.kodkast.com/blogs/hadoop/delegation-tokens-in-hadoop-security)
for more information.

      @call
        header: 'WebHDFS Passive'
        if: options.active_nn_host isnt options.fqdn
      , ->
        @system.execute
          cmd: mkcmd.test options.test_krb5_user, """
          curl -s --negotiate --insecure -u : "#{protocol}://#{address}/webhdfs/v1/user/#{options.test.user.name}?op=LISTSTATUS"
          kdestroy
          """
        , (err, data) ->
          throw err if err
          try
            valid = JSON.parse(data.stdout).RemoteException.exception is 'StandbyException'
          catch e then throw Error e
          throw Error "Invalid result" unless valid
      @call
        header: 'WebHDFS Active'
        if: options.active_nn_host is options.fqdn
      , ->
        protocol = if options.hdfs_site['dfs.http.policy'] is 'HTTP_ONLY' then 'http' else 'https'
        nameservice = if options.nameservice then ".#{options.nameservice}" else ''
        shortname = if options.nameservice then ".#{options.hostname}" else ''
        address = options.hdfs_site["dfs.namenode.#{protocol}-address#{nameservice}#{shortname}"]
        @system.execute
          cmd: mkcmd.test options.test_krb5_user, """
          hdfs --config '#{options.conf_dir}' dfs -touchz check-#{options.hostname}-webhdfs
          kdestroy
          """
          code_skipped: 2
        @system.execute
          cmd: mkcmd.test options.test_krb5_user, """
          curl -s --negotiate --insecure -u : "#{protocol}://#{address}/webhdfs/v1/user/#{options.test.user.name}?op=LISTSTATUS"
          kdestroy
          """
        , (err, data) ->
          throw err if err
          try
            count = JSON.parse(data.stdout).FileStatuses.FileStatus.filter((e) => e.pathSuffix is "check-#{options.hostname}-webhdfs").length
          catch e then throw Error e
          throw Error "Invalid result" unless count
        @system.execute
          cmd: mkcmd.test options.test_krb5_user, """
          curl -s --negotiate --insecure -u : "#{protocol}://#{address}/webhdfs/v1/?op=GETDELEGATIONTOKEN"
          kdestroy
          """
        , (err, data) ->
          throw err if err
          json = JSON.parse data.stdout
          return setTimeout do_tocken, 3000 if json.exception is 'RetriableException'
          token = json.Token.urlString
          @system.execute
            cmd: """
            curl -s --insecure "#{protocol}://#{address}/webhdfs/v1/user/#{options.test.user.name}?delegation=#{token}&op=LISTSTATUS"
            """
          , (err, data) ->
            throw err if err
            try
              count = JSON.parse(data.stdout).FileStatuses.FileStatus.filter((e) => e.pathSuffix is "check-#{options.hostname}-webhdfs").length
            catch e then throw Error e
            throw Error "Invalid result" unless count

## Dependencies

    mkcmd = require '../../lib/mkcmd'
