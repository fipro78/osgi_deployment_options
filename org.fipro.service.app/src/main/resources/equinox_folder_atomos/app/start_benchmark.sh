#!/bin/sh

JAVA_OPTS_ORIGINAL=$JAVA_OPTS
JAVA_OPTS="$JAVA_OPTS -Dcontainer.init=true"
. ./start.sh

if [ "$ITERATION_COUNT" = "" ];
then
  ITERATION_COUNT=10
fi

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS_ORIGINAL $JAVA_OPTS_EXTRA -Dbenchmark.appid=FOLDER_ATOMOS_MODULEPATH"$BENCHMARK_SUFFIX" -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  echo $USAGE $JAVA_OPTS
  . ./start.sh
done

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS_ORIGINAL $JAVA_OPTS_EXTRA -Dbenchmark.appid=FOLDER_ATOMOS_MODULEPATH"$BENCHMARK_SUFFIX"_CLEAN -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  echo $USAGE $JAVA_OPTS
  . ./start.sh org.osgi.framework.storage.clean=onFirstInit
done

USAGE="classpath"

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS_ORIGINAL $JAVA_OPTS_EXTRA -Dbenchmark.appid=FOLDER_ATOMOS_CLASSPATH"$BENCHMARK_SUFFIX" -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  echo $USAGE $JAVA_OPTS
  . ./start.sh
done

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS_ORIGINAL $JAVA_OPTS_EXTRA -Dbenchmark.appid=FOLDER_ATOMOS_CLASSPATH"$BENCHMARK_SUFFIX"_CLEAN -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  echo $USAGE $JAVA_OPTS
  . ./start.sh org.osgi.framework.storage.clean=onFirstInit
done