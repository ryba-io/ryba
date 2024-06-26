
export default
  header: 'Ambari Repo Install'
  handler: ({options}) ->
    @tools.repo
      if: [
        options.ambari.source or options.ambari.content
        options.ambari.enabled
      ]
      header: 'Ambari'
      source: options.ambari.source
      content: options.ambari.content
      target: options.ambari.target
      uid: 0
      gid: 0
      replace: options.ambari.replace
      update: true
    @tools.repo
      if: [
        options.hdp.source or options.hdp.content
        options.hdp.enabled
      ]
      header: 'HDP'
      source: options.hdp.source
      content: options.hdp.content
      target: options.hdp.target
      uid: 0
      gid: 0
      replace: options.hdp.replace
      update: true
