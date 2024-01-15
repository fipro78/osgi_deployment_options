@echo off

SET IMAGE_NAME=osgi-deployment%1-criu
podman run ^
  -d ^
  -p 11311:11311 ^
  --rm ^
  --cap-add=CHECKPOINT_RESTORE ^
  --cap-add=SYS_PTRACE ^
  --cap-add=SETPCAP ^
  --name %IMAGE_NAME% ^
  %IMAGE_NAME%:latest

echo
echo "Container started, you can now connect to the container via 'telnet localhost 11311'"