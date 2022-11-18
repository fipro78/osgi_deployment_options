#Using ghcr.io/graalvm/native-image you will always get the latest update available for Native Image, the latest OS, the latest Java version, and the latest GraalVM version.
#ARG IMAGE_NAME=ghcr.io/graalvm/native-image
#ARG VERSION=22.2.0
ARG IMAGE_NAME=ghcr.io/graalvm/graalvm-ce
ARG VERSION=ol8-java17-22.3.0

FROM ${IMAGE_NAME}:${VERSION} AS build

COPY /atomos_lib /build/atomos_lib
COPY /native-image-resources /build/native-image-resources
COPY /etc /result/etc
COPY /*.sh /result/


# Set up musl, in order to produce a static image compatible to alpine
# See 
# https://github.com/oracle/graal/issues/2824 and 
# https://github.com/oracle/graal/blob/vm-ce-22.0.0.2/docs/reference-manual/native-image/StaticImages.md
ARG RESULT_LIB="/musl"
RUN mkdir ${RESULT_LIB} && \
    curl -L -o musl.tar.gz https://more.musl.cc/10.2.1/x86_64-linux-musl/x86_64-linux-musl-native.tgz && \
    tar -xvzf musl.tar.gz -C ${RESULT_LIB} --strip-components 1 && \
    cp /usr/lib/gcc/x86_64-redhat-linux/8/libstdc++.a ${RESULT_LIB}/lib/
ENV CC=/musl/bin/gcc
RUN curl -L -o zlib.tar.gz https://zlib.net/zlib-1.2.13.tar.gz && \
    mkdir zlib && tar -xvzf zlib.tar.gz -C zlib --strip-components 1 && \
    cd zlib && ./configure --static --prefix=/musl && \
    make && make install && \
    cd / && rm -rf /zlib && rm -f /zlib.tar.gz
ENV PATH="$PATH:/musl/bin"


WORKDIR /build

RUN \
  gu install native-image && \
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
