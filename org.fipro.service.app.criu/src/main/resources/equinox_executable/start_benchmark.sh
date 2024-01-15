#!/bin/sh

if [ "$ITERATION" = "" ];
then
  ITERATION=1
fi

if [ "$BENCHMARK_HOST" = "" ];
then
  BENCHMARK_HOST=localhost
fi

# it is currently not possible to change or pass new parameters to a restored application, therefore this execution does not make sense now
# for i in $(seq $ITERATION_COUNT)
# do
#   THETIME=$(date +%s%3N)
#   JAVA_OPTS="$JAVA_OPTS $JAVA_OPTS_EXTRA -Dbenchmark.appid=EXECUTABLE"$BENCHMARK_SUFFIX" -Dbenchmark.executionid=$i -Dbenchmark.starttime=$THETIME -Dlaunch.keep=true -Dlaunch.storage.dir=/app/cache"
#   criu restore --unprivileged -D /app/checkpointData --shell-job -v4 --log-file=restore.log
# done

# write the information to a properties file so it can be retrieved by the application on restore
# needed because it is currently not possible to add or change environment variables effectively for a restored process
THETIME=$(date +%s%3N)
echo benchmark.appid=EXECUTABLE_OPENJ9_CRIU_CLEAN > /app/benchmark.properties
echo benchmark.executionid="$ITERATION" >> /app/benchmark.properties
echo benchmark.starttime="$THETIME" >> /app/benchmark.properties
echo benchmark.host="$BENCHMARK_HOST" >> /app/benchmark.properties

# restore the application
criu restore --unprivileged -D /app/checkpointData --shell-job -v4 --log-file=restore.log