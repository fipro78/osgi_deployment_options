FROM icr.io/appcafe/ibm-semeru-runtimes:open-17-jre-ubi9

ENV JAVA_OPTS_EXTRA="-XX:+EnableCRIUSupport"

# Need container.init=true as this triggers the immediate component that creates the checkpoint
ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true}"

USER root

# This doesn't seem to be necessary, as the capabilities are added on docker run
# RUN setcap cap_checkpoint_restore,cap_sys_ptrace,cap_setpcap=eip /usr/local/sbin/criu

EXPOSE 11311

COPY /app /app

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  mkdir -p /app/checkpointData
  
WORKDIR /app
CMD ["./start.sh"]
#CMD ["/bin/sh"]