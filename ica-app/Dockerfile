FROM wjallen/fsl:6.0.5

RUN wget https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm \
    && rpm -Uvh jdk-17_linux-x64_bin.rpm

#RUN wget https://nifti.nimh.nih.gov/pub/dist/src/fsliolib/imglob && \
#    chmod +x imglob && \
#    mv imglob /usr/local/bin/

COPY src/GingerALE.jar /app/GingerALE.jar
COPY src/make_lists_experiment_files_v5.m /app/make_lists_experiment_files_v5.m

RUN chmod +rx /app/*
