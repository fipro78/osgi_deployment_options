ARG IMAGE_NAME=ibm-semeru-runtimes
ARG VERSION=open-17-jre-jammy

FROM ${IMAGE_NAME}:${VERSION}

ARG EXECUTABLE_JAR=equinox-app.jar

EXPOSE 11311

RUN \
  useradd -s /bin/bash appuser
  
COPY --chown=appuser:appuser / /app

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  mv /app/$EXECUTABLE_JAR /app/app.jar

WORKDIR /app
USER appuser

CMD ["./start.sh"]