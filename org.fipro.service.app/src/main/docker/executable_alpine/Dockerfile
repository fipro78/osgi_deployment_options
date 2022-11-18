ARG IMAGE_NAME=eclipse-temurin
ARG VERSION=17-jre-alpine

ARG JAVA_OPTS_EXTRA

# Build Image

FROM ${IMAGE_NAME}:${VERSION} as build

ARG EXECUTABLE_JAR=equinox-app.jar

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true -Dlaunch.keep=true -Dlaunch.storage.dir=/app/cache}"

COPY / /app

RUN \
  apk --no-cache add tini && \
  rm /app/init_scc_size.sh && \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  mv /app/$EXECUTABLE_JAR /app/app.jar && \
  cd /app && \
  /sbin/tini /app/start.sh


# Production Image

FROM ${IMAGE_NAME}:${VERSION}

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

EXPOSE 11311

RUN \
  apk --no-cache add tini coreutils && \
  adduser -s /bin/false -D appuser

COPY --from=build --chown=appuser:appuser /app /app

WORKDIR /app
USER appuser

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["./start.sh"]
#CMD ["/bin/sh"]