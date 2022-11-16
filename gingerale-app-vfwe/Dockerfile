FROM openjdk:18.0.2.1-jdk

RUN microdnf upgrade && \
    microdnf install libXext libXrender libXtst

ADD ./src/GingerALE.jar /app/

