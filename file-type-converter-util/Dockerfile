FROM openjdk:17.0.2-jdk

RUN microdnf upgrade && \
    microdnf install libXext libXrender libXtst && \
    microdnf clean all

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
