#! /bin/bash

CONTAINER_PREFIX=osgi-deployment"$1"-criu
CONTAINER_NAME="$CONTAINER_PREFIX"-checkpoint

# first build the image to create the checkpoint
sudo podman build -t $CONTAINER_NAME .

# run the container with necessary capabilities
sudo podman run \
-t \
--cap-add=CHECKPOINT_RESTORE --cap-add=SYS_PTRACE --cap-add=SETPCAP \
--security-opt seccomp=unconfined \
--name $CONTAINER_NAME \
$CONTAINER_NAME

# get the container id to be able to create a new image from the container with the checkpoint data
CONTAINER_ID=$(sudo podman inspect --format="{{.Id}}" $CONTAINER_NAME)

# create a new image from the previous one that adds the checkpoint files
sudo podman container commit \
--change='CMD ["criu", "restore", "--unprivileged", "-D", "/app/checkpointData", "--shell-job", "-v4", "--log-file=restore.log"]' \
$CONTAINER_ID \
$CONTAINER_PREFIX

# Delete the checkpoint creation container
sudo podman container rm $CONTAINER_NAME
# Delete the checkpoint creation image
sudo podman image rm $CONTAINER_NAME

# Delete the dangling images
# sudo podman rmi $(sudo podman images -q --filter "dangling=true")
