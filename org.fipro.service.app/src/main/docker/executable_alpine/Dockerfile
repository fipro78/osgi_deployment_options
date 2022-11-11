ARG IMAGE_NAME=eclipse-temurin
ARG VERSION=17-jre-alpine

FROM ${IMAGE_NAME}:${VERSION}

ARG EXECUTABLE_JAR=equinox-app.jar

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

EXPOSE 11311

RUN \
  apk --no-cache add tini coreutils && \
  adduser -s /bin/false -D appuser

COPY --chown=appuser:appuser / /app

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  mv /app/$EXECUTABLE_JAR /app/app.jar

WORKDIR /app
USER appuser

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["./start.sh"]