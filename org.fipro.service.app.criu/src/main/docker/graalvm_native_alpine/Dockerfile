ARG IMAGE_NAME=container-registry.oracle.com/graalvm/native-image
ARG VERSION=21-muslib-ol9

FROM ${IMAGE_NAME}:${VERSION} AS build

COPY /atomos_lib /build/atomos_lib
COPY /native-image-resources /build/native-image-resources
COPY /etc /result/etc
COPY /*.sh /result/


WORKDIR /build

RUN \
# need to install findutils because find is not available in the slim base image
  microdnf install -y findutils && \
  dirlist=`find ./atomos_lib -type f -printf '%p:'` && \
  native-image \
#    -o atomos \
    --static \
    --libc=musl \
    --no-fallback \
    --initialize-at-build-time=org.apache.felix.atomos \
    --initialize-at-build-time=org.apache.felix.service.command.Converter \
    --class-path $dirlist \
    --verbose \
    -H:ConfigurationFileDirectories=native-image-resources \
    -H:+ReportUnsupportedElementsAtRuntime \
    -H:+ReportExceptionStackTraces \
    org.apache.felix.atomos.Atomos \
    atomos

RUN \
  mkdir -p /result && \
  mkdir -p /result/configuration && \
  cp /build/atomos /result && \
  cp -r /build/atomos_lib /result/atomos_lib

# The default ENTRYPOINT is "native-image", so we override that and call the native-image command with our parameters ourself
ENTRYPOINT ["bash"]  
CMD ["bash"]


FROM alpine:3
#gcr.io/distroless/static-debian11:debug

EXPOSE 11311

RUN \
  mkdir -p /app &&  \
  apk --no-cache add tini coreutils && \
  adduser -s /bin/false -D appuser

COPY --from=build --chown=appuser:appuser /result /app

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh
  
WORKDIR /app

USER appuser

ENTRYPOINT ["/sbin/tini", "--"]
CMD ["./start.sh"]
#CMD ["/bin/sh"]
