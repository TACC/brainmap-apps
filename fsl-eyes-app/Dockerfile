FROM continuumio/miniconda3:4.10.3

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libglu1-mesa-dev

RUN conda install -c conda-forge fsleyes 

# build everything above here, fsleyes works in dcv session on st2


RUN apt-get install -y build-essential \
    && apt-get install -y libpng-dev libmng-dev

# Download and install openblas
RUN wget https://github.com/xianyi/OpenBLAS/archive/v0.3.4.tar.gz \
    && tar -xvzf v0.3.4.tar.gz \
    && cd OpenBLAS-0.3.4 \
    && make -j2 \
    && make install \
    && cd ../ \
    && rm -rf OpenBLAS-0.3.4/ v0.3.4.tar.gz

ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:${LD_LIBRARY_PATH}

# Download and install fsl
RUN wget https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py \
    && python2 fslinstaller.py -o

RUN mkdir -p /usr/local/fsl \
    && tar -xvzf fsl-6.0.5-centos7_64.tar.gz  -C /usr/local/

# this fails, but might not be necessary
#ENV FSLDIR /usr/local/fsl
#RUN $FSLDIR/etc/fslconf/post_install.sh -f $FSLDIR

#RUN yum -y install libX11

# Clean up the container a bit
RUN apt-get clean all \
    && rm /fslinstaller.py \
    && rm /fsl-6.0.5-centos7_64.tar.gz \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/apt

ENV FSLDIR /usr/local/fsl
ENV PATH=${FSLDIR}/bin:${PATH}
ENV FSLMULTIFILEQUIT TRUE
ENV FSLTCLSH /usr/local/fsl/bin/fsltclsh 
ENV FSLWISH /usr/local/fsl/bin/fslwish
ENV FSLOUTPUTTYPE=NIFTI_GZ

