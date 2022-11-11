ARG IMAGE_NAME=eclipse-temurin
ARG VERSION=17-jdk-alpine

ARG MODULE_NAME=org.fipro.service.equinox.app
ARG BENCHMARK_APPID=JLINK

ARG JAVA_OPTS_EXTRA

FROM ${IMAGE_NAME}:${VERSION} AS build

ARG EXECUTABLE_JAR=equinox-app.jar
ARG MODULE_NAME
ARG EXTRA_MODULES=
ARG COMPRESS=0
ARG BENCHMARK_APPID

COPY $EXECUTABLE_JAR /tmp/$EXECUTABLE_JAR

RUN \
	mkdir -p /app/bin/ && \
	$JAVA_HOME/bin/jlink \
		--add-modules $MODULE_NAME${EXTRA_MODULES:+,$EXTRA_MODULES} \
		--compress=$COMPRESS \
		--module-path /tmp/$EXECUTABLE_JAR \
		--no-header-files \
		--no-man-pages \
		--output /app/jre

COPY /etc /app/etc
COPY /start* /app/bin/

RUN \
 chmod 755 /app/bin/start.sh && \
 chmod 755 /app/bin/start_benchmark.sh


FROM alpine:3

ARG MODULE_NAME
ENV MODULE_NAME=${MODULE_NAME}

ARG BENCHMARK_APPID
ENV BENCHMARK_APPID=${BENCHMARK_APPID}

ARG JAVA_OPTS_EXTRA
ENV JAVA_OPTS_EXTRA=${JAVA_OPTS_EXTRA}

# enable ZGC garbage collector - GC processing in parallel to the application, reduces GC pauses, in Java 11 only available via -XX:+UnlockExperimentalVMOptions
# ENV JAVA_OPTS="${JAVA_OPTS:--XX:+UseZGC}"

# enable Serial GC - useful in cloud for small workloads with less memory requirement, and where latency and response times are not relevant
# ENV JAVA_OPTS="${JAVA_OPTS:--XX:+UseSerialGC}"

# enable Parallel GC - like Serial GC but GC processing in parallel threads, NOT parallel to application, useful if focus is on performance
# ENV JAVA_OPTS="${JAVA_OPTS:--XX:+UseParallelGC}"

# enable Epsilon GC (from Java 17 onwards) - no-op GC, maximum performance as it does nothing, useful for "one-shot" containers where a container starts, executes a short running java process and stops
#ENV JAVA_OPTS="${JAVA_OPTS:--XX:+UnlockExperimentalVMOptions -XX:+UseEpsilonGC}"

EXPOSE 11311

RUN \
	apk --no-cache add tini coreutils && \
	adduser -s /bin/false -D appuser

COPY --from=build --chown=appuser:appuser /app /app

ENV PATH=/app/jre/bin:$PATH

WORKDIR /app
USER appuser

ENTRYPOINT ["/sbin/tini", "--"]

CMD ["/app/bin/start.sh"]
#CMD ["/bin/sh"]
