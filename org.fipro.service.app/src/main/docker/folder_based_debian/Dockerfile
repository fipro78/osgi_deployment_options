ARG IMAGE_NAME=ibm-semeru-runtimes
ARG VERSION=open-17-jre-jammy

FROM ${IMAGE_NAME}:${VERSION} as build

COPY /app /app

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true}"

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  cd /app && \
  /app/start.sh
  

FROM ${IMAGE_NAME}:${VERSION}

EXPOSE 11311

RUN useradd -s /bin/bash appuser
  
COPY --from=build --chown=appuser:appuser /app /app

WORKDIR /app
USER appuser

CMD ["./start.sh"]