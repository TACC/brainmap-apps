FROM wjallen/fsl:6.0.5

RUN yum install -y java-1.8.0-openjdk.x86_64 tree vim
COPY src/GingerALE.jar /app/GingerALE.jar
COPY src/MAR /MAR

RUN chmod +rx /app/GingerALE.jar && \
    chmod +rx /MAR/*

