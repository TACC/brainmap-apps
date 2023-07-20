FROM eclipse-temurin:19.0.2_7-jdk

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxtst6 libxext6 libxi6 libxrender1 

RUN apt-get install -y firefox

ADD ./src/Sleuth.jar /app/
