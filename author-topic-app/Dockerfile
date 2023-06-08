FROM ubuntu:18.04

# afni deps
RUN apt-get update \
    && apt-get install -y curl tree wget && \
    apt-get install -y software-properties-common && \
    apt-get update -y && \
    add-apt-repository -y universe && \
    apt-get update -y

RUN DEBIAN_FRONTEND=noninteractive TZ=America/Chicago apt-get install -y tzdata
 
RUN apt-get install -y tcsh xfonts-base python-qt4       \
                       python-matplotlib                 \
                       gsl-bin netpbm gnome-tweak-tool   \
                       libjpeg62 xvfb xterm vim curl     \
                       gedit evince eog                  \
                       libglu1-mesa-dev libglw1-mesa     \
                       libxm4 build-essential            \
                       libcurl4-openssl-dev libxml2-dev  \
                       libssl-dev libgfortran3           \
                       gnome-terminal nautilus           \
                       gnome-icon-theme-symbolic         \
                       firefox xfonts-100dpi

RUN ln -s /usr/lib/x86_64-linux-gnu/libgsl.so.23 /usr/lib/x86_64-linux-gnu/libgsl.so.19

RUN curl -O https://afni.nimh.nih.gov/pub/dist/bin/misc/@update.afni.binaries && \
    tcsh @update.afni.binaries -bindir /opt/abin -package linux_ubuntu_16_64 -do_extras

# older version of afni?
#RUN wget https://afni.nimh.nih.gov/pub/dist/tgz/AFNI_ARCHIVE/AFNI_16.0.00.tgz \ 
#    && tar -xzf AFNI_16.0.00.tgz -C /opt \
#    && rm /AFNI_16.0.00.tgz

# afni env
ENV PATH /opt/abin:$PATH
ENV R_LIBS /R

# R for afni
RUN mkdir /R && \
    curl -O https://afni.nimh.nih.gov/pub/dist/src/scripts_src/@add_rcran_ubuntu_18.04.tcsh && \
    tcsh @add_rcran_ubuntu_18.04.tcsh && \
    rPkgsInstall -pkgs ALL 

RUN cp /opt/abin/AFNI.afnirc ~/.afnirc && \
    apsearch -update_all_afni_help && \
    suma -update_env 

# clean up afni
RUN rm /@update.afni.binaries && \
    rm /@add_rcran_ubuntu_18.04.tcsh && \
    rm /@update_rcran.R


# freesurfer
RUN wget ftp://surfer.nmr.mgh.harvard.edu/pub/dist/freesurfer/5.3.0/freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz && \
    tar -xzf freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz -C /opt && \
    rm /freesurfer-Linux-centos4_x86_64-stable-pub-v5.3.0.tar.gz

COPY test/freesurfer_license /opt/freesurfer/.license

# freesurfer env 
ENV PATH /opt/freesurfer/bin:/opt/freesurfer/fsfast/bin:/opt/freesurfer/tktools:/opt/freesurfer/mni/bin:${PATH}
ENV FREESURFER_HOME /opt/freesurfer
RUN /bin/bash -c ' echo -e "source ${FREESURFER_HOME}/FreeSurferEnv.sh " >> /root/.bashrc '


# fsl 
RUN wget https://git.fmrib.ox.ac.uk/fsl/installer/-/raw/3.3.0/fslinstaller.py && \ 
    python fslinstaller.py -V 5.0.10 -d /opt/fsl && \
    rm /fslinstaller.py

# fsl env
ENV FSLDIR /opt/fsl
ENV PATH ${FSLDIR}/bin:$PATH
ENV LD_LIBRARY_PATH ${FSLDIR}/lib:$LD_LIBRARY_PATH
RUN /bin/bash -c ' echo -e "source ${FSLDIR}/etc/fslconf/fsl.sh " >> /root/.bashrc '


# CBIG assets
RUN wget https://github.com/ThomasYeoLab/CBIG/archive/refs/tags/v0.12.1-Ngo2019_AuthorTopic.tar.gz && \
    mkdir -p /opt/CBIG && \
    tar -xzf v0.12.1-Ngo2019_AuthorTopic.tar.gz  -C /opt/CBIG --strip-components=1 && \
    rm /v0.12.1-Ngo2019_AuthorTopic.tar.gz 

# CBIG env - CBIG_AuthorTopic_tested_config.sh
ENV CBIG_CODE_DIR=/opt/CBIG
ENV FREESURFER_HOME=/opt/freesurfer
ENV CBIG_MATLAB_DIR=/scratch/tacc/apps/matlab/2022b
ENV CBIG_AFNI_DIR=/opt/abin
ENV CBIG_FSLDIR=/opt/fsl

ENV SETUP_PATH=$CBIG_CODE_DIR/setup/CBIG_generic_setup.sh
#RUN source $SETUP_PATH


# patches
RUN cd /opt/CBIG/data/templates/volume/FSL_MNI152_FS4.5.0/mri && \
    mri_convert brain.mgz brain.mgh && \
    gunzip /opt/CBIG/stable_projects/meta-analysis/Ngo2019_AuthorTopic/utilities/mask/MNI_mask_conformed.2mm.0.1.nii.gz

RUN sed -i 's/brain.mgz/brain.mgh/' /opt/CBIG/stable_projects/meta-analysis/Ngo2019_AuthorTopic/utilities/preprocessing/CBIG_AuthorTopic_PreprocessExpDataFromText.m && \
    sed -i 's/nii.gz/nii/' /opt/CBIG/stable_projects/meta-analysis/Ngo2019_AuthorTopic/utilities/preprocessing/CBIG_AuthorTopic_PreprocessExpDataFromText.m && \
    sed -i 's/nii.gz/nii/' /opt/CBIG/stable_projects/meta-analysis/Ngo2019_AuthorTopic/utilities/preprocessing/CBIG_AuthorTopic_ConvertBrainImagesToCVBData.m && \
    sed -i 's/nii.gz/nii/' /opt/CBIG/stable_projects/meta-analysis/Ngo2019_AuthorTopic/utilities/inference/CBIG_AuthorTopic_SetupParameters.m && \
    sed -i 's/K, 3/K, 4/' /opt/CBIG/stable_projects/meta-analysis/Ngo2019_AuthorTopic/utilities/BIC/CBIG_AuthorTopic_EstimateComponentSmoothness.m


# #WORKDIR /opt/CBIG/external_packages/matlab/default_packages/cifti-matlab/
# #RUN mv \@gifti _gifti && \
# #    for FUNC in display fieldnames isfield plot save struct subsasgn subsref; do mv _gifti/${FUNC}.m _gifti/XXX${FUNC}.m; sed -i "s/ ${FUNC}(/ XXX${FUNC}(/g" ./_gifti/XXX${FUNC}.m; sed -i "s/ ${FUNC}(/ XXX${FUNC}(/g" ./_gifti/gifti.m; done
# #RUN mv \@gifti _gifti && \
# #    for FUNC in display fieldnames isfield plot save struct subsasgn subsref; do mv _gifti/${FUNC}.m _gifti/XXX${FUNC}.m; done
# #WORKDIR /

