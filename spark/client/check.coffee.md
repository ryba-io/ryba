
# Apache Spark Check

Run twice "[Spark Pi][Spark-Pi]" example for validating installation . The configuration is a 10 stages run.
[Spark on YARN][Spark-yarn] cluster can turn into two different mode :  yarn-client mode and yarn-cluster mode.
Spark programs are divided into a driver part and executors part.
The driver program manages the executors task.

    module.exports = header: 'Spark Check', label_true: 'CHECKED', handler: ->
      {spark, force_check,  user, core_site} = @config.ryba
      hive_server2 = @contexts 'ryba/hive/server2'
      [ranger_ctx] = @contexts 'ryba/ranger/admin'

## Wait

      @call once: true, 'ryba/hadoop/yarn_rm/wait'

## Check Cluster Mode

Validate Spark installation with Pi-example in yarn-cluster mode.

The YARN cluster mode makes the driver part of the spark submitted program to run inside YARN.
In this mode the driver is the YARN application master (running inside YARN).

      @call header: 'YARN Cluster', label_true: 'CHECKED', ->
        file_check = "check-#{@config.shortname}-spark-cluster"
        applicationId = null
        @system.execute
          cmd: mkcmd.test @, """
            spark-submit \
              --class org.apache.spark.examples.SparkPi \
              --master yarn-cluster --num-executors 2 --driver-memory 512m \
              --executor-memory 512m --executor-cores 1 \
              #{spark.client_dir}/lib/spark-examples*.jar 10 2>&1 /dev/null \
            | grep -m 1 "proxy\/application_";
          """
          unless_exec : unless force_check then mkcmd.test @, "hdfs dfs -test -f #{file_check}"
        , (err, executed, stdout, stderr) ->
          return err if err
          return unless executed
          tracking_url_result = stdout.trim().split("/")
          applicationId = tracking_url_result[tracking_url_result.length - 2]
        @call 
          if: -> @status -1
          handler:->
            @system.execute
              cmd: mkcmd.test @, """
              yarn logs -applicationId #{applicationId} 2>&1 /dev/null | grep -m 1 "Pi is roughly";
              """
            , (err, executed, stdout, stderr) ->
              return err if err
              return unless executed
              log_result = stdout.split(" ")
              pi = parseFloat(log_result[log_result.length - 1])
              return Error 'Invalid Output' unless pi > 3.00 and pi < 3.20
        @system.execute
          cmd: mkcmd.test @, """
          hdfs dfs -touchz #{file_check}
          """
          if: -> @status -2

## Check Client Mode

Validate Spark installation with Pi-example in yarn-client mode.

The YARN client mode makes the driver part of program to run on the local machine.
The local machine is the one from which the job has been submitted (called the client).
In this mode the driver is the spark master running outside yarn.

      @call header: 'YARN Client', label_true: 'CHECKED', ->
        file_check = "check-#{@config.shortname}-spark-client"
        applicationId = null
        @system.execute
          cmd: mkcmd.test @, """
            spark-submit \
              --class org.apache.spark.examples.SparkPi \
              --master yarn-client --num-executors 2 --driver-memory 512m \
              --executor-memory 512m --executor-cores 1 \
              #{spark.client_dir}/lib/spark-examples*.jar 10 2>&1 /dev/null \
            | grep -m 1 "Pi is roughly";
          """
          unless_exec : unless force_check then mkcmd.test @, "hdfs dfs -test -f #{file_check}"
        , (err, executed, stdout, stderr) ->
          return err if err
          return unless executed
          log_result = stdout.split(" ")
          pi = parseFloat(log_result[log_result.length - 1])
          return Error 'Invalid Output' unless pi > 3.00 and pi < 3.20
          return
        @system.execute
          cmd: mkcmd.test @, """
          hdfs dfs -touchz #{file_check}
          """
          if: -> @status -1

## Spark Shell (no hive)

Test spark-shell, in yarn-client mode. Spark-shell supports onyl local[*] mode and
yarn-client mode, not yarn-cluster.

      @call header: 'Shell (No SQL)', label_true: 'CHECKED', ->
        file_check = "check-#{@config.shortname}-spark-shell-scala"
        directory = "check-#{@config.shortname}-spark_shell_scala"
        db = "check_#{@config.shortname}_spark_shell_scala"
        @system.execute
          cmd: mkcmd.test @, """
          echo 'println(\"spark_shell_scala\")' | spark-shell --master yarn-client 2>/dev/null | grep ^spark_shell_scala$
          """
          unless_exec : unless force_check then mkcmd.test @, "hdfs dfs -test -f #{file_check}"
        , (err, executed, stdout) ->
          return err if err
          return unless executed
          return Error 'Invalid Output' unless stdout.indexOf 'spark_shell_scala' > -1
        @system.execute
          cmd: mkcmd.test @, """
          hdfs dfs -touchz #{file_check}
          """
          if: -> @status -1

## Spark Shell (no hive)

Executes hive queries to check communication with Hive.
Creating database from SparkSql is not supported for now.

      @call header: 'Shell (Hive SQL)', timeout: -1,label_true: 'CHECKED', ->
        return unless @contexts('ryba/hive/server2').length
        dir_check = "check-#{@config.shortname}-spark-shell-scala-sql"
        directory = "check-#{@config.shortname}-spark_shell_scala-sql"
        db = "check_#{@config.shortname}_spark_shell_hive_#{@config.shortname}"
        current = null
        url = null
        urls = hive_server2
        .map (hs2_ctx) =>
          quorum = hs2_ctx.config.ryba.hive.server2.site['hive.zookeeper.quorum']
          namespace = hs2_ctx.config.ryba.hive.server2.site['hive.server2.zookeeper.namespace']
          principal = hs2_ctx.config.ryba.hive.server2.site['hive.server2.authentication.kerberos.principal']
          url = "jdbc:hive2://#{quorum}/;principal=#{principal};serviceDiscoveryMode=zooKeeper;zooKeeperNamespace=#{namespace}"
          if hs2_ctx.config.ryba.hive.server2.site['hive.server2.use.SSL'] is 'true'
            url += ";ssl=true"
            url += ";sslTrustStore=#{@config.ryba.ssl_client['ssl.client.truststore.location']}"
            url += ";trustStorePassword=#{@config.ryba.ssl_client['ssl.client.truststore.password']}"
          if hs2_ctx.config.ryba.hive.server2.site['hive.server2.transport.mode'] is 'http'
            url += ";transportMode=#{hs2_ctx.config.ryba.hive.server2.site['hive.server2.transport.mode']}"
            url += ";httpPath=#{hs2_ctx.config.ryba.hive.server2.site['hive.server2.thrift.http.path']}"
          url
        .sort()
        .filter (c) ->
          p = current; current = c; p isnt c
        beeline = "beeline -u \"#{url}\" --silent=true "
        @call header: 'Add Hive Policy', if: ranger_ctx?, ->
          {install} = hive_server2[0].config.ryba.ranger.hive_plugin
          name = "Ranger-Ryba-Hive-Spark-Policy-#{@config.host}-client"
          dbs = []
          tables = []
          tables.push "check_#{@config.shortname}_spark_shell_hive_#{@config.shortname}"
          hive_policy =
            name: "#{name}"
            service: "#{install['REPOSITORY_NAME']}"
            repositoryType:"hive"
            description: 'Spark Shell Hive Check'
            isEnabled: true
            isAuditEnabled: true
            resources:
              database:
                isRecursive: false
                isExcludes: false
                values: tables
              column:
                isRecursive: false
                isExcludes: false
                values: ["*"]
              table:
                isRecursive: false
                isExcludes: false
                values: ["*"]
            policyItems: [{
              users: ["#{user.name}"]
              groups: []
              delegateAdmin: false
              accesses:[
                  "isAllowed": true
                  "type": "all"
              ]
              }]
          @system.execute
            cmd: """
            curl --fail -H "Content-Type: application/json" -k -X POST \
              -d '#{JSON.stringify hive_policy}' \
              -u admin:#{ranger_ctx.config.ryba.ranger.admin.password} \
              \"#{install['POLICY_MGR_URL']}/service/public/v2/api/policy\"
            """
            unless_exec: """
            curl --fail -H \"Content-Type: application/json\" -k -X GET  \
              -u admin:#{ranger_ctx.config.ryba.ranger.admin.password} \
              \"#{install['POLICY_MGR_URL']}/service/public/v2/api/service/#{install['REPOSITORY_NAME']}/policy/#{hive_policy.name}"
            """
            code_skipped: 22
        @call ->
          @system.execute
            cmd: mkcmd.test @, """
            hdfs dfs -rm -r -skipTrash #{directory} || true
            hdfs dfs -rm -r -skipTrash #{dir_check} || true
            hdfs dfs -mkdir -p #{directory}/my_db/spark_sql_test
            echo -e 'a,1\\nb,2\\nc,3' > /var/tmp/spark_sql_test
            #{beeline} \
              -e "DROP DATABASE IF EXISTS #{db};" \
              -e "CREATE DATABASE #{db} LOCATION '/user/#{user.name}/#{directory}/my_db/';"
            spark-shell --master yarn-client 2>/dev/null <<SPARKSHELL
            sqlContext.sql(\"USE #{db}\");
            sqlContext.sql(\"DROP TABLE IF EXISTS spark_sql_test\");
            sqlContext.sql(\"CREATE TABLE IF NOT EXISTS spark_sql_test (key STRING, value INT)\");
            sqlContext.sql(\"LOAD DATA LOCAL INPATH '/var/tmp/spark_sql_test' INTO TABLE spark_sql_test\");
            sqlContext.sql(\"FROM spark_sql_test SELECT key, value\").collect().foreach(println)
            sqlContext.sql(\"FROM spark_sql_test SELECT key, value\").rdd.saveAsTextFile(\"#{core_site['fs.defaultFS']}/user/#{user.name}/#{dir_check}\")
            SPARKSHELL
            #{beeline} \
              -e "DROP TABLE #{db}.spark_sql_test; DROP DATABASE #{db};"
            if hdfs dfs -test -f /user/#{user.name}/#{dir_check}/_SUCCESS; then exit 0; else exit 1;fi
            """
            unless_exec: unless force_check then mkcmd.test @, "hdfs dfs -test -f #{dir_check}/_SUCCESS"

## Spark Shell Python

      @call header: 'Shell (PySpark)', label_true: 'CHECKED', ->
        file_check = "check-#{@config.shortname}-spark-shell-python"
        directory = "check-#{@config.shortname}-spark_shell_python"
        db = "check_#{@config.shortname}_spark_shell_python"
        @system.execute
          cmd: mkcmd.test @, """
          echo 'print \"spark_shell_python\"' | pyspark  --master yarn-client 2>/dev/null | grep ^spark_shell_python$
          """
          unless_exec : unless force_check then mkcmd.test @, "hdfs dfs -test -f #{file_check}"
        , (err, executed, stdout) ->
          return err if err
          return unless executed
          return Error 'Invalid Output' unless stdout.indexOf 'spark_shell_python' > -1
        @system.execute
          cmd: mkcmd.test @, """
          hdfs dfs -touchz #{file_check}
          """
          if: -> @status -1

## Running Streaming Example

Original source code: https://github.com/apache/spark/blob/master/examples/src/main/scala/org/apache/spark/examples/streaming/KafkaWordCount.scala
Good introduction: http://www.michael-noll.com/blog/2014/10/01/kafka-spark-streaming-integration-example-tutorial/
Here's how to run the Kafka WordCount example:

```
spark-submit \
  --class org.apache.spark.examples.streaming.KafkaWordCount \
  --queue default \
  --master yarn-cluster  --num-executors 2 --driver-memory 512m \
  --executor-memory 512m --executor-cores 1 \
  /usr/hdp/current/spark-client/lib/spark-examples*.jar \
  master1.ryba:2181,master2.ryba:2181,master3.ryba:2181 \
  my-consumer-group topic1,topic2 1
```

## Dependencies

    mkcmd = require '../../lib/mkcmd'

[Spark-Pi]:http://docs.hortonworks.com/HDPDocuments/HDP2/HDP-2.2.4/Apache_Spark_Quickstart_v224/content/run_spark_pi.html
[Spark-yarn]:http://blog.cloudera.com/blog/2014/05/apache-spark-resource-management-and-yarn-app-models/
