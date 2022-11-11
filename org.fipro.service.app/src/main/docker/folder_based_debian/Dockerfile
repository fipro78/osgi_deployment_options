ARG IMAGE_NAME=ibm-semeru-runtimes
ARG VERSION=open-17-jre-jammy

ARG JAVA_OPTS_EXTRA

FROM ${IMAGE_NAME}:${VERSION} as build

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

COPY /app /app

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true}"

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  cd /app && \
  /app/start.sh
  

FROM ${IMAGE_NAME}:${VERSION}

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

EXPOSE 11311

RUN useradd -s /bin/bash appuser
  
COPY --from=build --chown=appuser:appuser /app /app

WORKDIR /app
USER appuser

CMD ["./start.sh"]