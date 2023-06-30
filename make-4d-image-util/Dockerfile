FROM wjallen/fsl:6.0.5

RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm \
    && rpm -Uvh jdk-17_linux-x64_bin.rpm

COPY src/GingerALE.jar /app/GingerALE.jar

RUN chmod +rx /app/*
