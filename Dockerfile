FROM jupyter/minimal-notebook:python-3.11

# Set root to install system packages
USER root

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
      build-essential \
      git \
      wget \
      libgfortran5 \
      bzip2 \
      libgl1 \
      openjdk-11-jdk \
      ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set SNAP-related env variables
ENV SNAPVER=11 \
    SNAP_HOME=/usr/local/esa-snap \
    JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Prepare SNAP installation
RUN mkdir -p /src/snap
COPY response.varfile /src/snap/response.varfile

# Install SNAP
RUN wget -q -O /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh \
    "https://step.esa.int/downloads/${SNAPVER}.0/installers/esa-snap_all_linux-${SNAPVER}.0.0.sh" && \
    sh /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh -q -varfile /src/snap/response.varfile && \
    rm -f /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh

# Fix permissions for conda cache before switching to non-root user
RUN mkdir -p /home/jovyan/.cache/conda && \
    chown -R ${NB_UID}:${NB_GID} /home/jovyan/.cache

# Switch back to notebook user (UID 1000)
USER ${NB_UID}

# Create and activate a conda environment named snap
RUN conda create -n snap python=3.11 -y && \
    conda clean -afy

# Install Python packages in 'snap' environment
RUN conda run -n snap python -m pip install esa_snappy jpy

# Add SNAP bin to PATH
ENV PATH="${PATH}:/usr/local/esa-snap/bin"

# Auto-activate conda env in notebooks and shells
RUN echo "conda activate snap" >> ~/.bashrc

# Ensure environment is activated in Binder
ENV CONDA_DEFAULT_ENV=snap
ENV PATH=/opt/conda/envs/snap/bin:$PATH

# Optional test (comment out in production)
RUN conda run -n snap python -c "import esa_snappy; print('SNAP-Python interface working')"