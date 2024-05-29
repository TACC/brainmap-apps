FROM openjdk:17.0.2-jdk

RUN microdnf upgrade && \
    microdnf install unzip libXext libXrender libXtst && \
    microdnf clean all

ADD ./src /app/src
ADD ./run.sh /app

RUN cd /app/src && \
    unzip SdmPsiGui-linux64-v6.23.zip && \
    rm SdmPsiGui-linux64-v6.23.zip && \
    chmod +x /app/src/SdmPsiGui-linux64-v6.23/bin/linux64/SdmPsiGui && \
    chmod -R go=u /app && \
    chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
