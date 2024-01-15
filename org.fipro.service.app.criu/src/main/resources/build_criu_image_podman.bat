@echo off
setlocal EnableDelayedExpansion

SET CONTAINER_PREFIX=osgi-deployment%1-criu
SET CONTAINER_NAME=%CONTAINER_PREFIX%-checkpoint

rem first build the image to create the checkpoint
podman build -t %CONTAINER_NAME% .

rem run the container with necessary capabilities
podman run ^
-t ^
--cap-add=CHECKPOINT_RESTORE --cap-add=SYS_PTRACE --cap-add=SETPCAP ^
--security-opt seccomp=unconfined ^
--name %CONTAINER_NAME% ^
%CONTAINER_NAME%

rem get the container id to be able to create a new image from the container with the checkpoint data
for /f %%i in ('docker inspect --format="{{.Id}}" %CONTAINER_NAME%') do set CONTAINER_ID=%%i

rem create a new image from the previous one that adds the checkpoint files
podman container commit ^
--change="CMD [\"criu\", \"restore\", \"--unprivileged\", \"-D\", \"/app/checkpointData\", \"--shell-job\", \"-v4\", \"--log-file=restore.log\"]" ^
%CONTAINER_ID% ^
%CONTAINER_PREFIX%

rem Delete the checkpoint creation container
podman container rm %CONTAINER_NAME%
rem Delete the checkpoint creation image
podman image rm %CONTAINER_NAME%

rem Delete the dangling images
for /f %%i in ('podman images -q --filter "dangling=true"') do set DANGLING_ID=%%i
podman rmi %DANGLING_ID%
