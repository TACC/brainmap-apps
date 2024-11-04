FROM python:3.9.18-bullseye

RUN apt-get update && apt-get install -y \
    freeglut3-dev \
    git \
    libgtk-3-0 \
    libgl1-mesa-glx \
    libxcb-cursor-dev \
    pyqt5-dev \
    pyqt5-dev-tools \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /app/ && \
    python3 -m venv /app/datalad-gooey 

ENV PATH="/app/datalad-gooey/bin:$PATH"

RUN pip install datalad==1.1.3 datalad-gooey==0.2.0
RUN pip install datalad_next==0.6.3

ADD ./run.sh /app/run.sh

RUN chmod -R go=u /app && \
    chmod +x /app/run.sh

ENTRYPOINT ["/bin/bash", "/app/run.sh"]

