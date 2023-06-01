FROM openjdk:17.0.2-jdk

RUN microdnf upgrade && \
    microdnf install libXext libXrender libXtst libXt

COPY ./src/xGTM_portal /xGTM_portal

RUN chmod -R +rx /xGTM_portal/