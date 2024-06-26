
import {merge} from 'mixme'

export default ({options, node, deps}) ->
  # Identities
  options.test_user = merge deps.ambari_server[0].options.test_user, options.test_user
  options.test_group = merge deps.ambari_server[0].options.test_group, options.test_group
  # Environment
  options.fqdn = node.fqdn
  options.conf_dir ?= '/etc/ambari-agent/conf'
  # Identities
  options.hadoop_group = merge deps.ambari_server[0].options.hadoop_group, options.hadoop_group
  options.group = merge deps.ambari_server[0].options.group, options.group
  options.user = merge deps.ambari_server[0].options.user, options.user
  options.test_group = merge deps.ambari_server[0].options.test_group, options.test_group
  options.test_user = merge deps.ambari_server[0].options.test_user, options.test_user
  # Configuration
  options.config ?= {}
  options.config.server ?= {}
  options.config.server['hostname'] ?= "#{deps.ambari_server[0].node.fqdn}"
  options.config.server['url_port'] = deps.ambari_server[0].options.config['server.url_port']
  options.config.server['secured_url_port'] = deps.ambari_server[0].options.config['server.secured_url_port']
  options.config.agent ?= {}
  options.config.agent['hostname_script'] ?= "#{options.conf_dir}/hostname.sh"
  options.config.agent['parallel_execution'] ?= 0
  options.config.agent['run_as_user'] ?= 'root'
  # Ambari Rest Api URL
  # options.ambari_url ?= deps.ambari_server[0].options.ambari_url
  # options.ambari_admin_password ?= deps.ambari_server[0].options.admin_password
  # options.cluster_name ?= deps.ambari_server[0].options.cluster_name
  # Cluster Provisionning
  # options.provision_cluster ?= deps.ambari_server[0].options.provision_cluster
  # User Provisionning
  # Contains object of user that ambari-agent should create on all hosts. By default
  # Ambari needs to all user on all node even if the service is not installed on a host.
  # The components should register their user to ambari agents
  options.users ?= {}
  options.groups ?= {}
  # Wait Ambari
  options.wait_ambari_rest = deps.ambari_server[0].options.wait.rest
  options.wait ?= {}
  options.wait.rpc = for srv in deps.ambari_agent
    host: srv.node.fqdn
    port: 8670
