
export default (service) ->
  options = service.options

  # OpenJDK

  options.openjdk ?= false

  # Oracle JDK

  options.jdk ?= {}
  options.jdk.root_dir ?= '/usr/java'
  options.jdk.version ?= '1.8.0_202'
  options.jdk.versions ?=
    '1.8.0_202':
      jdk:
        source: "https://download.oracle.com/otn-pub/java/jdk/8u202-b08/1961070e4c9b4e26a04e7f5a083f551e/jdk-8u202-linux-x64.tar.gz"
        md5: "0029351f7a946f6c05b582100c7d45b7" 
      jce:
        source: "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip"
        md5: "b3c7031bc65c28c2340302065e7d00d3"
  # options.jdk.versions['1.7.0_79'] ?= {}
  # options.jdk.versions['1.7.0_79'].jdk_location ?= "http://download.oracle.com/otn-pub/java/jdk/7u79-b15/jdk-7u79-linux-x64.tar.gz"
  # options.jdk.versions['1.7.0_79'].jdk_sha256 ?= "29d75d0022bfa211867b876ddd31a271b551fa10727401398295e6e666a11d90"
  # options.jdk.versions['1.7.0_79'].jce_location ?= "http://download.oracle.com/otn-pub/java/jce/7/UnlimitedJCEPolicyJDK7.zip"
  # options.jdk.versions['1.7.0_79'].jce_sha256 ?= "7a8d790e7bd9c2f82a83baddfae765797a4a56ea603c9150c87b7cdb7800194d"

  # Java properties

  options.java_home ?= "#{options.jdk.root_dir}/default"
  options.java_home = options.java_home.replace /\/+$/, "" # remove trailing slashes
  options.jre_home ?= "#{options.java_home}/jre"
  options.jre_home = options.jre_home.replace /\/+$/, "" # remove trailing slashes

  # Command Specific

  # Ensure "prepare" is executed locally only once
  options.prepare = service.node.id is service.instances[0].node.id
