# Base image
FROM ubuntu:24.04

# Environment variables
ENV DEBIAN_FRONTEND=noninteractive \
    LC_ALL=C.UTF-8 \
    LANG=C.UTF-8 \
    SNAPVER=11 \
    SNAP_HOME=/usr/local/esa-snap \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Create a non-root user with UID 1000
ARG NB_USER=jovyan
ARG NB_UID=1000
ENV USER=${NB_USER}
ENV NB_UID=${NB_UID}
ENV HOME=/home/${NB_USER}
RUN useradd -m -s /bin/bash -N -u ${NB_UID} ${NB_USER}

# Install system dependencies
RUN apt-get update && \
    apt-get install -y \
      build-essential \
      git \
      wget \
      python3 \
      python3-pip \
      libgfortran5 \
      bzip2 \
      ca-certificates \
      libgl1 \
      openjdk-11-jdk && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install Jupyter Notebook and JupyterLab
RUN python3 -m pip install --no-cache-dir notebook jupyterlab

# Optional: Install JupyterHub if needed
# RUN python3 -m pip install --no-cache-dir jupyterhub

# Set working directory
WORKDIR /src/snap

# Copy response file for SNAP installation
COPY response.varfile .

# Install SNAP
RUN wget -q -O esa-snap_all_unix_${SNAPVER}_0_0.sh \
    "https://step.esa.int/downloads/${SNAPVER}.0/installers/esa-snap_all_linux-${SNAPVER}.0.0.sh" && \
    sh esa-snap_all_unix_${SNAPVER}_0_0.sh -q -varfile response.varfile && \
    rm -f esa-snap_all_unix_${SNAPVER}_0_0.sh

# Copy and run SNAP update script
COPY update_snap.sh .
RUN chmod +x update_snap.sh && \
    ./update_snap.sh

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Set Conda environment variables
ENV PATH="/opt/conda/bin:$PATH"

# Initialize Conda for bash
RUN conda init bash

# Create Python 3.11 environment named 'snap'
RUN conda create -n snap python=3.11 -y && \
    conda clean -afy

# Install packages in the 'snap' environment
RUN /opt/conda/bin/conda run -n snap python -m pip install esa_snappy jpy

# Ensure the site-packages directory exists
RUN mkdir -p /opt/conda/envs/snap/lib/python3.11/site-packages

# Add gpt to PATH
ENV PATH="${PATH}:/usr/local/esa-snap/bin"

# Set Conda environment to activate automatically
RUN echo "conda activate snap" >> /home/${NB_USER}/.bashrc && \
    echo "conda activate snap" >> /etc/profile.d/conda.sh

# Change ownership to the non-root user
RUN chown -R ${NB_USER}:${NB_USER} /home/${NB_USER}

# Switch to non-root user
USER ${NB_USER}

# Set working directory
WORKDIR /home/${NB_USER}

# Test installations
RUN python --version && \
    conda run -n snap python -c "import esa_snappy; print('SNAP-Python interface working')" && \
    gpt -h
