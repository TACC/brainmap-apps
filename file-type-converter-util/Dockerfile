FROM eclipse-temurin:17.0.7_7-jdk

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxt6 && \
    apt-get clean

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
