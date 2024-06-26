
# Atlas Solr Collection Bootstrap

    export default headler: 'SolrCloud Ranger Layout', handler: ({options}) ->
      # migration: lucasbak 02112017
      # use this bootstrap scripts for every type
      return unless options.solr_type is 'external'
      protocol = if options.solr.cluster_config.ssl_enabled then 'https' else 'http'

## Wait

      @connection.wait options.wait_solr

## Collection Layout

      @file.download
        source: "#{__dirname}/../resources/solr/managed-schema"
        target: "#{options.solr.cluster_config.ranger_collection_dir}/managed-schema"
      @file.render
        source: "#{__dirname}/../resources/solr/solrconfig.xml.j2"
        target: "#{options.solr.cluster_config.ranger_collection_dir}/solrconfig.xml"
        local: true
        context: retention_period: options.audit_retention_period
      @file.download
        source: "#{__dirname}/../resources/solr/elevate.xml"
        target: "#{options.solr.cluster_config.ranger_collection_dir}/elevate.xml"
      @file.download
        source: "#{__dirname}/../resources/solr/elevate.xml"
        target: "#{options.solr.cluster_config.ranger_collection_dir}/elevate.xml"

## Create Atlas Collection in Solr

      @call
        header: "Create ranger_audits collection"
        unless_exec: mkcmd.solr options.solr.cluster_config, """
          curl --fail --negotiate -k -u : \
          "#{protocol}://#{options.solr.cluster_config['master']}:#{options.solr.cluster_config['port']}/solr/admin/collections?action=LIST" | grep ranger_audits
        """
      , ->
        @system.execute
          cmd: mkcmd.solr options.solr.cluster_config, """
          #{options.solr_client_source}/server/scripts/cloud-scripts/zkcli.sh  \
          -zkhost #{options.solr.cluster_config.zk_connect} \
          -cmd upconfig \
          -confdir #{options.solr.cluster_config.ranger_collection_dir} \
          -confname ranger_audits
        """
        @system.execute
          cmd: mkcmd.solr options.solr.cluster_config, """
            curl --fail --negotiate -k -u : "#{protocol}://#{options.solr.cluster_config['master']}:#{options.solr.cluster_config['port']}/solr/#{getPath(options.solr.cluster_config.collection)}"
          """
        #equivalent to
        #curl  --negotiate -k -u : "http://docker01.metal.ryba8983/solr/admin/collections?action=CREATE&name=ranger_audits&numShards=3&replicationFactor=2&collection.configName=ranger_audits&maxShardsPerNode=2"

## Zookeeper Znode ACL

      @system.execute
        header: 'Zookeeper SolrCloud Znode ACL'
        unless_exec: mkcmd.solr options.solr.cluster_config, """
        zookeeper-client -server #{options.solr.cluster_config.zk_connect} \
          getAcl #{options.solr.cluster_config.zk_node} | grep \"'sasl,'#{options.solr.cluster_config.user}\"
        """
        cmd: mkcmd.solr options.solr.cluster_config, """
        zookeeper-client -server #{options.solr.cluster_config.zk_connect} \
          setAcl #{options.solr.cluster_config.zk_node} sasl:#{options.solr.cluster_config.user}:cdrwa
        """

    getPath = (opts) ->
      path = "admin/collections?action=CREATE"
      path += "&#{param}=#{opts[param]}" for param in [
        'name'
        'numShards'
        'replicationFactor'
        'collection.configName'
        'maxShardsPerNode'
        # 'createNodeSet'
      ]
      return path

## Dependencies

    mkcmd = require '../../lib/mkcmd'
