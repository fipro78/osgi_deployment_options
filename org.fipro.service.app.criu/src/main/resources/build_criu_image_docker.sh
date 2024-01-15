#! /bin/bash

CONTAINER_PREFIX=osgi-deployment"$1"-criu
CONTAINER_NAME="$CONTAINER_PREFIX"-checkpoint

# first build the image to create the checkpoint
docker build -t $CONTAINER_NAME .

# run the container with necessary capabilities
docker run \
-t \
--cap-drop=ALL \
--cap-add=CHECKPOINT_RESTORE --cap-add=SYS_PTRACE --cap-add=SETPCAP \
--security-opt seccomp=unconfined \
--name $CONTAINER_NAME \
$CONTAINER_NAME

# get the container id to be able to create a new image from the container with the checkpoint data
CONTAINER_ID=$(docker inspect --format="{{.Id}}" $CONTAINER_NAME)

# create a new image from the previous one that adds the checkpoint files
docker container commit \
--change='CMD ["criu", "restore", "--unprivileged", "-D", "/app/checkpointData", "--shell-job", "-v4", "--log-file=restore.log"]' \
$CONTAINER_ID \
$CONTAINER_PREFIX

# Delete the checkpoint creation container
docker container rm $CONTAINER_NAME
# Delete the checkpoint creation image
docker image rm $CONTAINER_NAME

# Delete the dangling images
# docker rmi $(docker images -q --filter "dangling=true")
