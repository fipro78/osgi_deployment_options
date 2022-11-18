ARG IMAGE_NAME=ibm-semeru-runtimes
ARG VERSION=open-17-jre-jammy

ARG JAVA_OPTS_EXTRA

# Build Image

FROM ${IMAGE_NAME}:${VERSION} as build

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

ENV JAVA_OPTS="${JAVA_OPTS:--Dcontainer.init=true}"

COPY /app /app

RUN \
  chmod 755 /app/start.sh && \
  chmod 755 /app/start_benchmark.sh && \
  chmod 755 /app/init_scc_size.sh && \
  cd /app && \
  /app/init_scc_size.sh && \
  rm /app/init_scc_size.sh  
  

# Production Image

FROM ${IMAGE_NAME}:${VERSION}

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

EXPOSE 11311

RUN useradd -s /bin/bash appuser
  
COPY --from=build --chown=appuser:appuser /app /app

WORKDIR /app
USER appuser

CMD ["./start.sh"]
#CMD ["/bin/sh"]