#!/bin/sh
IMAGE_NAME=osgi-deployment"$1"-criu

if [ "$2" = "" ];
then
  ITERATION_COUNT=10
else
  ITERATION_COUNT=$2
fi

if [ "$3" != "skip_benchmark_service" ];
then
  # create network that is shared between benchmark service and criu application
  sudo podman network create benchmark_network

  # start the benchmark service container
  sudo podman run \
    -d \
    --rm \
    -p 8080:8080 \
    --network benchmark_network \
    --name benchmark_service \
    osgi-benchmark-app:17_temurin 

  # wait until service is available
  until $(curl --output /dev/null --silent --head --fail http://127.0.0.1:8080/benchmark/details); do
      printf '.'
      sleep 1
  done
fi

# it is not possible to restart a application multiple times inside the container because of missing temporary files between starts
# start the criu container multiple times and pass the execution id as environment parameter to the container

for i in $(seq $ITERATION_COUNT)
do
  sudo podman run \
    -d \
    --rm \
    -p 11311:11311 \
    --network benchmark_network \
    --cap-drop=ALL \
    --cap-add=CHECKPOINT_RESTORE \
    --cap-add=SYS_PTRACE \
    --cap-add=SETPCAP \
    --env ITERATION=$i \
    --env BENCHMARK_HOST=benchmark_service \
    --name $IMAGE_NAME \
    "$IMAGE_NAME":latest \
    ./start_benchmark.sh

    sleep 2
done
