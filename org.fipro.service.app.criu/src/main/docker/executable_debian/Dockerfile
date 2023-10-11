ARG IMAGE_NAME=icr.io/appcafe/ibm-semeru-runtimes
ARG VERSION=open-17-jre-ubi9

ARG JAVA_OPTS_EXTRA=-XX:+EnableCRIUSupport

# Build Image

FROM ${IMAGE_NAME}:${VERSION} as build

ARG EXECUTABLE_JAR=equinox-app.jar

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true -Dlaunch.keep=true -Dlaunch.storage.dir=/app/cache}"

COPY / /app

USER root

RUN setcap cap_checkpoint_restore,cap_sys_ptrace,cap_net_admin=eip /usr/local/sbin/criu

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  mv /app/$EXECUTABLE_JAR /app/app.jar && \
  cd /app && \
  mkdir /app/checkpointData
#  mkdir /app/checkpointData && \
#  /app/start.sh

CMD ["/bin/sh"]

# Production Image

# FROM ${IMAGE_NAME}:${VERSION}

# ARG JAVA_OPTS_EXTRA
# ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

# EXPOSE 11311

# RUN \
#   useradd -s /bin/bash appuser
  
# COPY --from=build --chown=appuser:appuser /app /app

# WORKDIR /app
# USER appuser

# CMD ["./start.sh"]
# CMD ["/bin/sh"]