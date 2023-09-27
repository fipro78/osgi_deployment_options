FROM ubuntu:20.04

ARG EXECUTABLE_JAR=equinox-app.jar

ENV JAVA_HOME /opt/jdk
ENV PATH $JAVA_HOME/bin:$PATH

ENV JAVA_OPTS_EXTRA=-XX:CRaCCheckpointTo=/opt/crac-files

EXPOSE 11311

RUN apt-get update -y
ADD "https://cdn.azul.com/zulu/bin/zulu17.42.21-ca-crac-jdk17.0.7-linux_x64.tar.gz" $JAVA_HOME/openjdk.tar.gz
RUN tar --extract --file $JAVA_HOME/openjdk.tar.gz --directory "$JAVA_HOME" --strip-components 1; rm $JAVA_HOME/openjdk.tar.gz;
RUN mkdir -p /opt/crac-files

COPY / /opt/app

RUN \
  chmod 755 /opt/app/start.sh && \
  chmod 755 /opt/app/start_benchmark.sh && \
  mv /opt/app/$EXECUTABLE_JAR /opt/app/app.jar

WORKDIR /opt/app
CMD ["./start.sh"]
# CMD ["java", "-XX:CRaCCheckpointTo=/opt/crac-files", "-jar", "app.jar"]
