FROM openjdk:17.0.2-jdk

RUN microdnf install unzip

RUN curl -O http://rii.uthscsa.edu/mango/downloads/mango_unix.zip \
    && unzip mango_unix.zip

COPY ./src/Plugins /Plugins
RUN chmod -R go=u /Plugins
