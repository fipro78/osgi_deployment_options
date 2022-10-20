ARG IMAGE_NAME=gcr.io/distroless/java17-debian11

FROM ${IMAGE_NAME}

ARG EXECUTABLE_JAR

EXPOSE 11311
  
COPY $EXECUTABLE_JAR app.jar
COPY /etc /etc

CMD ["app.jar"]