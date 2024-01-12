FROM wjallen/fsl:6.0.5

RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm && \
    rpm -Uvh jdk-17_linux-x64_bin.rpm

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm /Miniconda3-latest-Linux-x86_64.sh /anaconda-post.log

ENV PATH="${PATH}:/opt/miniconda3/bin"

RUN pip3 install numpy scipy nibabel==4.0.2
RUN yum install -y numactl && \
    yum clean all

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
