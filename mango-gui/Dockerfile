FROM openjdk:17.0.2-jdk

RUN microdnf upgrade && \
    microdnf install unzip libXext libXrender libXtst && \
    microdnf clean all

ADD ./src /app/src
ADD ./run.sh /app

RUN cd /app/src && \
    unzip mango_unix.zip && \
    rm mango_unix.zip && \
    chmod -R go=u /app && \
    chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
