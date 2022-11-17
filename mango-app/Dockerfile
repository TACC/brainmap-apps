FROM openjdk:7-jdk

RUN wget http://rii.uthscsa.edu/mango/downloads/mango_unix.zip \
    && unzip mango_unix.zip

COPY ./src/Plugins /Plugins
RUN chmod -R go=u /Plugins

