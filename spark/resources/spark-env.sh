#!/usr/bin/env bash

# This file is sourced when running various Spark programs.
# Copy it as spark-env.sh and edit that to configure Spark for your site.

# Options read in YARN client mode
#SPARK_EXECUTOR_INSTANCES="2" #Number of workers to start (Default: 2)
#SPARK_EXECUTOR_CORES="1" #Number of cores for the workers (Default: 1).
#SPARK_EXECUTOR_MEMORY="1G" #Memory per Worker (e.g. 1000M, 2G) (Default: 1G)
#SPARK_DRIVER_MEMORY="512 Mb" #Memory for Master (e.g. 1000M, 2G) (Default: 512 Mb)
#SPARK_YARN_APP_NAME="spark" #The name of your application (Default: Spark)
#SPARK_YARN_QUEUE="~@~Xdefault~@~Y" #The hadoop queue to use for allocation requests (Default: @~Xdefault~@~Y)
#SPARK_YARN_DIST_FILES="" #Comma separated list of files to be distributed with the job.
#SPARK_YARN_DIST_ARCHIVES="" #Comma separated list of archives to be distributed with the job.

# Generic options for the daemons used in the standalone deploy mode

# Alternate conf dir. (Default: ${SPARK_HOME}/conf)
export SPARK_CONF_DIR=${SPARK_HOME:-/usr/hdp/current/spark-client}/conf

# Where log files are stored.(Default:${SPARK_HOME}/logs)
#export SPARK_LOG_DIR=${SPARK_HOME:-/usr/hdp/current/spark-client}/logs
export SPARK_LOG_DIR=/var/log/spark

# Where the pid file is stored. (Default: /tmp)
export SPARK_PID_DIR=/var/run/spark

# A string representing this instance of spark.(Default: $USER)
SPARK_IDENT_STRING=$USER

# The scheduling priority for daemons. (Default: 0)
SPARK_NICENESS=0

export HADOOP_HOME=${HADOOP_HOME:-/usr/hdp/current/hadoop-client}
export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-{{ryba.hadoop_conf_dir}}}

# The java implementation to use.
export JAVA_HOME={{java.java_home}}

if [ -d "{{ryba.tez.env['TEZ_CONF_DIR']}}" ]; then
  export TEZ_CONF_DIR={{ryba.tez.env['TEZ_CONF_DIR']}}
else
  export TEZ_CONF_DIR=
fi
