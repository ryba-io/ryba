
# Ranger Atlas Metadata Server Ranger Plugin Install

    export default header: 'Ranger Atlas Plugin install', handler: ({options}) ->
      version = null
      #https://mail-archives.apache.org/mod_mbox/incubator-ranger-user/201605.mbox/%3C363AE5BD-D796-425B-89C9-D481F6E74BAF@apache.org%3E

## Register

      @registry.register 'hdfs_mkdir', '@rybajs/metal/lib/hdfs_mkdir'
      @registry.register 'ranger_user', '@rybajs/metal/ranger/actions/ranger_user'
      @registry.register 'ranger_policy', '@rybajs/metal/ranger/actions/ranger_policy'
      @registry.register 'ranger_service', '@rybajs/metal/ranger/actions/ranger_service'

## Wait

      @call '@rybajs/metal/ranger/admin/wait', once: true, options.wait_ranger_admin

# Packages

      @call header: 'Packages', ->
        @system.execute
          header: 'Setup Execution Version'
          shy:true
          cmd: """
          hdp-select versions | tail -1
          """
         , (err, data) ->
            return  err if err or not data.status
            version = data.stdout.trim() if data.status
        @service
          name: "ranger-atlas-plugin"

## Ranger User

      @ranger_user
        header: 'Ranger User'
        username: options.ranger_admin.username
        password: options.ranger_admin.password
        url: options.install['POLICY_MGR_URL']
        user: options.plugin_user

## Audit Layout


# Create Atlas Policy for On HDFS Repo

      @call
        header: 'Audit HDFS Policy'
        if: options.install['XAAUDIT.HDFS.IS_ENABLED'] is 'true'
      , ->
        @system.mkdir
          header: 'HDFS Spool Dir'
          if: options.install['XAAUDIT.HDFS.IS_ENABLED'] is 'true'
          target: options.install['XAAUDIT.HDFS.FILE_SPOOL_DIR']
          uid: options.atlas_user.name
          gid: options.atlas_group.name
          mode: 0o0750
        @system.mkdir
          target: options.install['XAAUDIT.SOLR.FILE_SPOOL_DIR']
          uid: options.atlas_user.name
          gid: options.atlas_group.name
          mode: 0o0750
          if: options.install['XAAUDIT.SOLR.IS_ENABLED'] is 'true'
        @call ->
          for target in options.policy_hdfs_audit.resources.path.values
            @hdfs_mkdir
              target: target
              mode: 0o0750
              parent:
                mode: 0o0711
                user: options.user.name
                group: options.group.name
              uid: options.atlas_user.name
              gid: options.atlas_group.name
              krb5_user: options.hdfs_krb5_user
        @ranger_policy
          username: options.ranger_admin.username
          password: options.ranger_admin.password
          url: options.install['POLICY_MGR_URL']
          policy: options.policy_hdfs_audit

## Service Repository creation

Matchs step 1 in [Atlas plugin configuration][plugin]. Instead of using the web ui
we execute this task using the rest api.

      @ranger_service
        header: 'Ranger Repository'
        username: options.ranger_admin.username
        password: options.ranger_admin.password
        url: options.install['POLICY_MGR_URL']
        service: options.service_repo

Note, by default, we're are using the same Ranger principal for every
plugin and the principal is created by the Ranger Admin service. Chances
are that a customer user will need specific ACLs but this hasn't been
tested.

      @krb5.addprinc options.krb5.admin,
        header: 'Plugin Principal'
        principal: "#{options.service_repo.configs.username}"
        password: options.service_repo.configs.password

# Plugin Scripts 

      @call ->
        @file
          header: 'Scripts rendering'
          if: -> version?
          source: "#{__dirname}/../../resources/plugin-install.properties"
          target: "/usr/hdp/#{version}/ranger-atlas-plugin/install.properties"
          local: true
          eof: true
          backup: true
          write: for k, v of options.install
            match: RegExp "^#{quote k}=.*$", 'mg'
            replace: "#{k}=#{v}"
            append: true
        @file
          header: 'Script Fix'
          target: "/usr/hdp/#{version}/ranger-atlas-plugin/enable-atlas-plugin.sh"
          write: [
              match: RegExp "^HCOMPONENT_CONF_DIR=.*$", 'mg'
              replace: "HCOMPONENT_CONF_DIR=#{options.conf_dir}"
            ,
              match: RegExp "^HCOMPONENT_INSTALL_DIR_NAME=.*$", 'mg'
              replace: "HCOMPONENT_INSTALL_DIR_NAME=/usr/hdp/current/atlas-server"
            ,
              match: RegExp "^HCOMPONENT_LIB_DIR=.*$", 'mg'
              replace: "HCOMPONENT_LIB_DIR=/usr/hdp/current/atlas-server/lib"
          ]
          backup: true
          mode: 0o750
        @call header: 'Enable Atlas Plugin', (_, callback) ->
          files = ['ranger-atlas-audit.xml','ranger-atlas-security.xml','ranger-policymgr-ssl.xml']
          sources_props = {}
          current_props = {}
          files_exists = {}
          @system.execute
            cmd: """
            echo '' | keytool -list \
              -storetype jceks \
              -keystore /etc/ranger/#{options.install['REPOSITORY_NAME']}/cred.jceks | egrep '.*ssltruststore|auditdbcred|sslkeystore'
            """
            code_skipped: 1
          @call
            if: -> @status -1 #do not need this if the cred.jceks file is not provisioned
          , ->
            @each files, (opts, cb) ->
              file = opts.key
              target = "#{options.conf_dir}/#{file}"
              ssh = @ssh options.ssh
              fs.exists ssh, target, (err, exists) ->
                return cb err if err
                return cb() unless exists
                files_exists["#{file}"] = exists
                properties.read ssh, target , (err, props) ->
                  return cb err if err
                  sources_props["#{file}"] = props
                  cb()
          @system.execute
            header: 'Script Execution'
            cmd: """
            if /usr/hdp/#{version}/ranger-atlas-plugin/enable-atlas-plugin.sh ;
              then exit 0 ;
              else exit 1 ;
              fi;
            """
          @file.types.hfile
            header: 'Fix ranger-atlas-security conf'
            target: "#{options.conf_dir}/ranger-atlas-security.xml"
            merge: true
            properties:
              'ranger.plugin.atlas.policy.rest.ssl.config.file': "#{options.conf_dir}/ranger-policymgr-ssl.xml"
          @system.chown
            header: 'Fix Permissions'
            target: "/etc/ranger/#{options.install['REPOSITORY_NAME']}/.cred.jceks.crc"
            uid: options.atlas_user.name
            gid: options.atlas_group.name
          @file.types.hfile
            header: 'JAAS Properties for solr'
            target: "#{options.conf_dir}/ranger-atlas-audit.xml"
            merge: true
            properties: options.audit
          @each files, (opts, cb) ->
            file = opts.key
            target = "#{options.conf_dir}/#{file}"
            ssh = @ssh options.ssh
            fs.exists ssh, target, (err, exists) ->
              return callback err if err
              properties.read ssh, target , (err, props) ->
                return cb err if err
                current_props["#{file}"] = props
                cb()
          @call
            header: 'Compare Current Config Files'
            shy: true
          , ->
            for file in files
              #do not need to go further if the file did not exist
              return callback null, true unless sources_props["#{file}"]?
              for prop, value of current_props["#{file}"]
                return callback null, true unless value is sources_props["#{file}"][prop]
              for prop, value of sources_props["#{file}"]
                return callback null, true unless value is current_props["#{file}"][prop]
              return callback null, false

## Dependencies

    quote = require 'regexp-quote'
    path = require 'path'
    mkcmd = require '../../../lib/mkcmd'
    properties = require '../../../lib/properties'
    fs = require 'ssh2-fs'

[atlas-plugin]:(https://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.4.0/bk_installing_manually_book/content/installing_ranger_plugins.html#installing_ranger_atlas_plugin)
