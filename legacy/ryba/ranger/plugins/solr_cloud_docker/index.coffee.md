# Ranger Solr Plugin
Install Solr Plugin by default on solr_cloud_docker host.

    export default
      deps:
        krb5_client: module: 'masson/core/krb5_client', local: true, required: true
        java: module: 'masson/commons/java', local: true
        hadoop_core: module: '@rybajs/metal/hadoop/core', local: true, auto: true, implicit: true
        hdfs_client: module: '@rybajs/metal/hadoop/hdfs_client', local: true, auto: true, implicit: true
        solr_cloud_docker: module: '@rybajs/metal/solr/cloud_docker', local: true, required: true
        ranger_hdfs: module: '@rybajs/metal/ranger/plugins/hdfs', required: true
        ranger_admin: module: '@rybajs/metal/ranger/admin', single: true, required: true
        ranger_solr_cloud_docker: module: '@rybajs/metal/ranger/plugins/solr_cloud_docker'
      configure:
        '@rybajs/metal/ranger/plugins/solr_cloud_docker/configure'
      plugin: ({options}) ->
        @before
          action: ['docker', 'compose','up']
        , ->
          delete options.original.action
          delete options.original.handler
          delete options.original.argument
          delete options.original.store
          @call '@rybajs/metal/ranger/plugins/solr_cloud_docker/install', options.original
