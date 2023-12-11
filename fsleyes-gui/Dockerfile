FROM python:3.9.18-bullseye

RUN apt-get update && \ 
    apt-get upgrade -y && \
    apt-get install -y build-essential && \
    apt-get install -y libgtk2.0-dev libgtk-3-dev libwebkit2gtk-4.0-dev && \
    apt-get install -y libjpeg-turbo-progs libtiff5-dev libsdl1.2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libnotify-dev && \
    apt-get clean

RUN pip install wxpython==4.1.1
RUN pip install fsleyes

ADD ./run.sh /app/
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]

