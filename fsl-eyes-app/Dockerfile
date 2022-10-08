FROM continuumio/miniconda3:4.11.0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxxf86vm-dev \
                       libgl-dev \
                       libglu1-mesa-dev

RUN conda install -c conda-forge fsleyes

