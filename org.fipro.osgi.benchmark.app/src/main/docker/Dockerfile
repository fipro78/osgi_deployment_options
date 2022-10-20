ARG IMAGE_NAME=eclipse-temurin
ARG VERSION=17-jre-alpine

FROM ${IMAGE_NAME}:${VERSION}

ARG EXECUTABLE_JAR

EXPOSE 8080

RUN \
  mkdir -p /app && \
  apk --no-cache add tini && \
  adduser -s /bin/false -D appuser && \
  echo '#!/bin/sh' > /app/start && \
  echo "java -jar app.jar" >> /app/start && \
  chmod 755 /app/start && \
  chown appuser:appuser /app/start
  
COPY --chown=appuser:appuser $EXECUTABLE_JAR /app/app.jar

WORKDIR /app
USER appuser

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["./start"]