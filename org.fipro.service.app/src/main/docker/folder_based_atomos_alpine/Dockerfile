ARG IMAGE_NAME=eclipse-temurin
ARG VERSION=17-jre-alpine

ARG USAGE=modulepath

ARG JAVA_OPTS_EXTRA

# Build Image

FROM ${IMAGE_NAME}:${VERSION} as build

ARG USAGE
ENV USAGE=${USAGE}

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true}"

COPY /app /app

RUN \
  apk --no-cache add tini && \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  cd /app && \
  /sbin/tini /app/start.sh
  

# Production Image

FROM ${IMAGE_NAME}:${VERSION}

ARG USAGE
ENV USAGE=${USAGE}

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
