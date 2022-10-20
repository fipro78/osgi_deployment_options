ARG IMAGE_NAME=eclipse-temurin
ARG VERSION=17-jre-alpine

FROM ${IMAGE_NAME}:${VERSION} as build

COPY /app /app

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true}"

RUN \
  apk --no-cache add tini && \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  cd /app && \
  /sbin/tini /app/start.sh
  

FROM ${IMAGE_NAME}:${VERSION}

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
