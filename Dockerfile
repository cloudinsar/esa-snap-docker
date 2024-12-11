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
      libgfortran5

LABEL authors="Michele Claus"
LABEL maintainer="michele.claus@eurac.edu"

ENV SNAPVER 11

RUN mkdir -p /src/snap
COPY response.varfile /src/snap/response.varfile

# install and update snap
RUN wget -q -O /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh "https://step.esa.int/downloads/${SNAPVER}.0/installers/esa-snap_all_linux-${SNAPVER}.0.0.sh"

RUN sh /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh -q -varfile /src/snap/response.varfile

# Remove installer to spare some space
RUN rm -f /src/snap/esa-snap_all_unix_${SNAPVER}_0_0.sh

# update SNAP
COPY update_snap.sh /src/snap/update_snap.sh
RUN sh /src/snap/update_snap.sh

# add gpt to PATH
ENV PATH="${PATH}:/usr/local/esa-snap/bin"

# test gpt
RUN gpt -h