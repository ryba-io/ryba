
## Dependencies

import each from 'each'
import path from 'path'
import string from '@nikitajs/core/utils/string'

export default header: 'JAVA Install', handler: ({options}) ->
  {root_dir} = options.jdk
  
  # Install OpenJDK

  @service
    header: 'OpenJDK'
    if: -> options.openjdk
    name: 'java-1.8.0-openjdk-devel'

  @call
    header: 'Oracle JDKs'
    if: -> options.jdk
  , ->
    installed_versions = null
    @system.mkdir
      target: root_dir
    @system.execute
      header: "List Installed JDK"
      # Better than ls, it ignores links and empty dirs
      cmd: "find #{root_dir} -mindepth 1 -maxdepth 1 -not -empty -type d"
      # cmd: "ls -d #{root_dir}/*"
      # code_skipped: 2
      shy: true
    , (err, data) ->
      throw err if err
      stdout = '' unless data.status
      installed_versions = (string.lines data.stdout.trim())
        .filter (out) -> out if /jdk(.*)/.exec out
        .map (abs) -> "#{path.basename abs}"
    @system.mkdir root_dir
    @service.install
      header: 'Dependency unzip'
      if: Object.keys(options.jdk.versions).length
      name: 'unzip'
    @each options.jdk.versions, ({options}, callback) ->
      version = options.key
      jdk = options.value
      installed = installed_versions.indexOf("jdk#{version}") isnt -1
      path_name = "#{path.basename jdk.jce.source, '.zip'}"
      now = Date.now()
      @call
        header: "JDK #{version}"
        unless: -> installed
      , ->
        @file.download
          source: jdk.jdk.source
          target: "/tmp/java.#{now}/#{path.basename jdk.jdk.source}"
          location: true
          cookies: ['oraclelicense=a']
        @system.mkdir "#{root_dir}/jdk#{version}"
        @tools.extract
          source: "/tmp/java.#{now}/#{path.basename jdk.jdk.source}"
          target: "#{root_dir}/jdk#{version}"
          strip: 1
        @system.remove "/tmp/java.#{now}/#{path.basename jdk.jdk.source}"
      @call
        header: "JCE #{version}"
      , ->
        @file.download
          source: "#{jdk.jce.source}"
          target: "/var/tmp/#{path.basename jdk.jce.source}"
          location: true
          cookies: ['oraclelicense=a']
          shy: true
        @system.mkdir "/tmp/#{path_name}.#{now}", shy: true
        @system.mkdir "/tmp/#{path_name}", shy: true
        @tools.extract
          source: "/var/tmp/#{path.basename jdk.jce.source}"
          target: "/tmp/#{path_name}.#{now}"
          shy: true
        @system.execute
          cmd: "mv  /tmp/#{path_name}.#{now}/*/* /tmp/#{path_name}/"
          shy: true
        @system.copy
          source: "/tmp/#{path_name}/local_policy.jar"
          target: "#{root_dir}/jdk#{version}/jre/lib/security/local_policy.jar"
        @system.copy
          source: "/tmp/#{path_name}/US_export_policy.jar"
          target: "#{root_dir}/jdk#{version}/jre/lib/security/US_export_policy.jar"
        @system.remove "/tmp/#{path_name}", shy: true
      @next callback

  # Java Paths

  @system.execute
    header: 'Set default JDK'
    cmd: """
    if [ -L  "#{root_dir}/default" ] || [ -e "#{root_dir}/default" ] ; then
      source=`readlink #{root_dir}/default`
      if [ "$source" == "#{root_dir}/jdk#{options.jdk.version}" ]; then
        exit 3
      else
        rm -f #{root_dir}/default
        ln -sf #{root_dir}/jdk#{options.jdk.version} #{root_dir}/default
        exit 0
      fi
    else
      rm -f #{root_dir}/default
      ln -sf #{root_dir}/jdk#{options.jdk.version} #{root_dir}/default
      exit 0
    fi
    """
    code_skipped: 3
    trap: true
  @system.execute
    header: 'Set latest JDK'
    cmd: """
    if [ -L  "#{root_dir}/latest" ] || [ -e "#{root_dir}/latest" ] ; then
      source=`readlink #{root_dir}/latest`
      if [ "$source" == "#{root_dir}/jdk#{options.jdk.version}" ]; then
        exit 3
      else
        rm -f #{root_dir}/latest
        ln -sf #{root_dir}/jdk#{options.jdk.version} #{root_dir}/latest
        exit 0
      fi
    else
      rm -f #{root_dir}/latest
      ln -sf #{root_dir}/jdk#{options.jdk.version} #{root_dir}/latest
      exit 0
    fi
    """
    code_skipped: 3
    trap: true
  @system.execute
    header: 'Link Java home'
    unless: options.java_home is "#{root_dir}/default"
    cmd: """
    if [ -L  "#{options.java_home}" ] || [ -e "#{options.java_home}" ] ; then
      source=`readlink #{options.java_home}`
      if [ "$source" == "#{options.java_home}" ]; then
        exit 3
      else
        rm -f #{options.java_home}
        ln -sf #{root_dir}/default #{options.java_home}
        exit 0
      fi
    else
      rm -f #{options.java_home}
      ln -sf #{root_dir}/default #{options.java_home}
      exit 0
    fi
    """
    code_skipped: 3
    trap: true
  @file
    header: 'Java Env'
    target: '/etc/profile.d/java.sh'
    mode: 0o0644
    content: """
    export JAVA_HOME=#{options.java_home}
    export PATH=#{options.java_home}/bin:$PATH
    """
