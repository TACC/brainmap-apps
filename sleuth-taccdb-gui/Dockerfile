FROM eclipse-temurin:19.0.2_7-jdk

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxtst6 libxext6 libxi6 libxrender1 && \
    apt-get clean

RUN apt-get install -y firefox

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
