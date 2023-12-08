FROM eclipse-temurin:8-jdk

RUN apt update && \
    apt upgrade -y && \
    apt-get install -y libxrender1 libxtst6 libxi6 && \
    apt-get clean

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
