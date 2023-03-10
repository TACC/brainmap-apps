FROM openjdk:17.0.2-jdk

RUN microdnf upgrade && \
    microdnf install unzip libXext libXrender libXtst

COPY ./src/Plugins /app/Plugins
COPY ./src/mango_unix.zip /app/

RUN cd /app && \
    unzip mango_unix.zip && \
    rm mango_unix.zip && \
    chmod -R go=u /app
