#!/bin/sh

if [ "$ITERATION_COUNT" = "" ];
then
  ITERATION_COUNT=10
fi

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS_ORIGINAL -Dbenchmark.appid=GRAALVM -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  . /app/start.sh
done

for i in $(seq $ITERATION_COUNT)
do
  THETIME=$(date +%s%3N)
  JAVA_OPTS="$JAVA_OPTS_ORIGINAL -Dbenchmark.appid=GRAALVM_CLEAN -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME"
  . /app/start.sh org.osgi.framework.storage.clean=onFirstInit
done
