FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8

RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      wget \
      python3 \
      libgfortran5 \
      bzip2 \
      ca-certificates \
      libgl1 \
      openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

LABEL authors="Michele Claus"
LABEL maintainer="michele.claus@eurac.edu"

ENV SNAPVER=11 \
    SNAP_HOME=/usr/local/esa-snap \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

RUN mkdir -p /src/snap
COPY response.varfile /src/snap/response.varfile

# Install SNAP
RUN wget -q -O /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh \
    "https://step.esa.int/downloads/${SNAPVER}.0/installers/esa-snap_all_linux-${SNAPVER}.0.0.sh" && \
    sh /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh -q -varfile /src/snap/response.varfile && \
    rm -f /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh

# Fixed update script
COPY update_snap.sh /src/snap/update_snap.sh
RUN chmod +x /src/snap/update_snap.sh && \
    /src/snap/update_snap.sh

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda.sh && \
    bash ~/miniconda.sh -b -p /opt/conda && \
    rm ~/miniconda.sh


ENV PATH="/opt/conda/bin:$PATH"

RUN conda init bash

# Create Python 3.11 environment
RUN conda create -n snap python=3.11 -y && \
    conda clean -afy

# Install packages in the snap environment
RUN /opt/conda/bin/conda run -n snap python -m pip install esa_snappy jpy

# Ensure the site-packages directory exists
RUN mkdir -p /opt/conda/envs/snap/lib/python3.11/site-packages

# add gpt to PATH
ENV PATH="${PATH}:/usr/local/esa-snap/bin"

# Set conda environment to activate automatically for both login and non-login shells
RUN echo "conda activate snap" >> ~/.bashrc && \
    echo "conda activate snap" >> /etc/profile.d/conda.sh

# test gpt
# 5. Verification
RUN python --version && \
    /opt/conda/bin/conda run -n snap python -c "import esa_snappy; print('SNAP-Python interface working')" && \
    gpt -h