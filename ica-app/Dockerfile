FROM wjallen/fsl:6.0.5

RUN yum install -y java-1.8.0-openjdk.x86_64 tree vim

#RUN wget https://nifti.nimh.nih.gov/pub/dist/src/fsliolib/imglob && \
#    chmod +x imglob && \
#    mv imglob /usr/local/bin/

COPY src/GingerALE.jar /app/GingerALE.jar
COPY src/make_lists_experiment_files_v5.m /app/make_lists_experiment_files_v5.m

RUN chmod +rx /app/*
