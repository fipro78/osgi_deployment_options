#!/bin/sh

if [ "$ITERATION_COUNT" = "" ];
then
  ITERATION_COUNT=10
fi

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS $JAVA_OPTS_EXTRA -Dbenchmark.appid=EXECUTABLE"$BENCHMARK_SUFFIX" -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME -Dlaunch.keep=true -Dlaunch.storage.dir=/app/cache"
  . ./start.sh
done

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS $JAVA_OPTS_EXTRA -Dbenchmark.appid=EXECUTABLE"$BENCHMARK_SUFFIX"_CLEAN -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  . ./start.sh
done