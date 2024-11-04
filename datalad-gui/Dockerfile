FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    git \
    libdbus-1-dev \
    libfontconfig-dev \
    libgl1-mesa-dev \
    libxkbcommon-dev \
    libxcb-cursor-dev \
    qt6-base-dev \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /app/miniconda3 && \
    rm /Miniconda3-latest-Linux-x86_64.sh

ENV PATH="${PATH}:/app/miniconda3/bin"

RUN pip3 install datalad==1.1.3 datalad-gooey==0.2.0
RUN pip3 install datalad_next==0.6.3
RUN pip3 install pyqt6==6.7.1

ENV PYTHON_KEYRING_BACKEND="keyring.backends.null.Keyring"

ADD ./run.sh /app/run.sh

RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]

