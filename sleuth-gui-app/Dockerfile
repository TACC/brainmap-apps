FROM openjdk:8-jdk

RUN apt update -y && \
    apt upgrade -y && \
    apt-get install -y \
        libxrender1 \
        libxtst6 \
        libxi6

RUN mkdir -p /app/ && \
    cd /app/ && \
    wget http://brainmap.org/sleuth/Sleuth.jar
