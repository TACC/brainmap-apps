FROM wjallen/fsl:6.0.5

RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm \
    && rpm -Uvh jdk-17_linux-x64_bin.rpm

RUN yum install -y libXt

RUN rm /jdk-17_linux-x64_bin.rpm /anaconda-post.log

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
