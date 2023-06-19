#Using ghcr.io/graalvm/native-image you will always get the latest update available for Native Image, the latest OS, the latest Java version, and the latest GraalVM version.
ARG IMAGE_NAME=ghcr.io/graalvm/native-image
ARG VERSION=muslib-ol9-java17-22.3.2

FROM ${IMAGE_NAME}:${VERSION} AS build

COPY /atomos_lib /build/atomos_lib
COPY /native-image-resources /build/native-image-resources


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

# The default ENTRYPOINT is "native-image", so we override that and call the native-image command with our parameters ourself
ENTRYPOINT ["bash"]  
CMD ["bash"]


FROM scratch

EXPOSE 11311

COPY --from=build /build/atomos /
COPY --from=build /build/atomos_lib /atomos_lib
COPY /etc /etc

CMD ["/atomos", "gosh.home=/", "gosh.args=--nointeractive -c telnetd -i 0.0.0.0 -p 11311 start"]
