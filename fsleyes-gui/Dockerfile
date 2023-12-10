FROM centos:7

RUN  yum -y update && \
     yum -y install epel-release && \
     yum -y install wget mesa-libGL mesa-libOSMesa && \
     wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
     sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
     yum clean all && \
     rm /Miniconda3-latest-Linux-x86_64.sh

RUN /opt/miniconda3/bin/conda install -y -c conda-forge fsleyes
RUN ln -s /opt/miniconda3/bin/fsleyes /usr/local/bin/fsleyes

ADD ./run.sh /app/
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
