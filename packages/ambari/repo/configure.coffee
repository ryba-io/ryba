import path from 'path'

export default ({options}) ->

  options.ambari ?= {}
  options.ambari.enabled ?= true
  options.ambari.source ?= null
  options.ambari.target ?= 'ambari.repo'
  options.ambari.target = path.posix.resolve '/etc/yum.repos.d', options.ambari.target
  options.ambari.replace ?= 'ambari*'
  
  # Note, Ambari will deploy the repository
  options.hdp ?= {}
  options.hdp.enabled ?= false
  options.hdp.source ?= null
  options.hdp.target ?= 'hdp.repo'
  options.hdp.target = path.posix.resolve '/etc/yum.repos.d', options.hdp.target
  options.hdp.replace ?= 'hdp*'
