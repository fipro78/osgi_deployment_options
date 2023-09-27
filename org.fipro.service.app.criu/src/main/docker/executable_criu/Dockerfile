FROM ibm-semeru-runtimes:open-17-jre-jammy

ARG EXECUTABLE_JAR=equinox-app.jar

ENV JAVA_OPTS_EXTRA=-XX:+EnableCRIUSupport


EXPOSE 11311

COPY $EXECUTABLE_JAR /opt/app/app.jar
COPY start.sh /opt/app/start.sh

RUN \
  chmod 755 /opt/app/start.sh

# RUN \
#   chmod 755 /opt/app/start.sh && \
#   chmod 755 /opt/app/start_benchmark.sh && \
#   mv /opt/app/$EXECUTABLE_JAR /opt/app/app.jar

WORKDIR /opt/app
CMD ["./start.sh"]
