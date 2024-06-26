
# Hadoop YARN Timeline Reader Install

The Timeline Reader is a stand-alone server daemon and doesn't need to be
co-located with any other service.

    export default header: 'YARN ATS HBase Conf Install', handler: ({options}) ->
      return if options.yarn_hbase_embedded

## HBase Backend Client Configuration

      @call
        header: 'HBase Client Configuration'
      , ->
        @system.mkdir
          unless: options.hbase_local
          target: "#{options.ats2_hbase_conf_dir}"
          uid: options.ats_user.name
          gid: options.hadoop_group.name
          mode: 0o775
        @file.types.hfile
          unless: options.hbase_local
          header: 'HBase Site'
          target: "#{options.ats2_hbase_conf_dir}/hbase-site.xml"
          properties: options.hbase_site
          backup: true
          user: options.ats_user.name
          group: options.hadoop_group.name  

## Dependencies

    path = require 'path'
    mkcmd = require '../../lib/mkcmd'
