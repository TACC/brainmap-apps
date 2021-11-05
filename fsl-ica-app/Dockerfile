FROM centos:7

# update, grab a recent gcc and openblas
RUN yum -y update \
    && yum -y groupinstall "Development Tools" \
    && yum -y install which wget \
    && yum -y install libpng12 libmng

# Download and install openblas
RUN curl -LO https://github.com/xianyi/OpenBLAS/archive/v0.3.4.tar.gz \
    && tar -xvzf v0.3.4.tar.gz \
    && cd OpenBLAS-0.3.4 \
    && make -j2 \
    && make install \
    && cd ../ \
    && rm -rf OpenBLAS-0.3.4/ v0.3.4.tar.gz

ENV LD_LIBRARY_PATH=/opt/OpenBLAS/lib:${LD_LIBRARY_PATH}

# Download and install fsl
RUN curl -LO https://fsl.fmrib.ox.ac.uk/fsldownloads/fslinstaller.py \
    && python fslinstaller.py -d /usr/local/fsl

# Clean up the container a bit
RUN yum -y clean all \
    && rm /anaconda-post.log \
    && rm /fslinstaller.py \
    && rm -rf /tmp/* \
    && rm -rf /var/cache/yum


ENV FSLDIR /usr/local/fsl
ENV PATH=${FSLDIR}/bin:${PATH}
ENV FSLMULTIFILEQUIT TRUE
ENV FSLTCLSH /usr/local/fsl/bin/fsltclsh
ENV FSLWISH /usr/local/fsl/bin/fslwish
ENV FSLOUTPUTTYPE=NIFTI_GZ
