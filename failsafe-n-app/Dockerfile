FROM openjdk:17.0.2-jdk

RUN microdnf upgrade && \
    microdnf install libXext libXrender libXtst wget && \
    microdnf clean all

RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    sh Miniconda3-latest-Linux-x86_64.sh -b -p /opt/miniconda3 && \
    rm /Miniconda3-latest-Linux-x86_64.sh

ENV PATH="${PATH}:/opt/miniconda3/bin"

RUN pip3 install \
            "ipython>=8.14.0" \
            "matplotlib>=3.7.1" \
            "numpy>=1.24.3" \
            "pandas>=2.0.2" \
            "scikit-learn>=1.2.2" \
            "scipy>=1.10.1"

ADD ./src /app/src
ADD ./run.sh /app
RUN chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]
