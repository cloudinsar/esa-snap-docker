FROM jupyter/minimal-notebook:python-3.10

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
      ca-certificates \
      python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /requirements.txt
RUN pip3 install -r /requirements.txt

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

# Switch back to notebook user (UID 1000)
USER ${NB_UID}

# Add SNAP bin to PATH
ENV PATH="${PATH}:/usr/local/esa-snap/bin"

RUN snap --nogui --nosplash --modules --install eu.esa.snap.esa.snappy

# Install Python packages in 'snap' environment
# RUN snap --nogui --nosplash --snappy /usr/bin/python3.10 /usr/bin/lib/python3.10/site-packages/

# Optional test (comment out in production)
#RUN conda run -n snap python -c "import esa_snappy; print('SNAP-Python interface working')"