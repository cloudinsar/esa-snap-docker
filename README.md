# ESA SNAP 11 docker

**The content of this repository is still work in progress!**

Dockerized version of SNAP 11 with the Sentinel-1 toolbox.

Based on Ubuntu 24.04.

How to use it:

Clone the repository:
```
git clone https://github.com/clausmichele/esa-snap-docker.git
```

Build the docker image:
```
docker build -t esa-snap-11 .
```

Use it:
```
docker run -it -v /home/ubuntu/preprocessing/:/src/preprocessing/ esa-snap-11 gpt /src/preprocessing/pre-processing_stackOverview_2images.xml -Pinput1=/src/preprocessing/S1A_SLC_20240811T165248_311760_IW2_VV_027360.SAFE/manifest.safe -Pinput2=/src/preprocessing/S1A_SLC_20240823T165249_311760_IW2_VV_022944.SAFE/manifest.safe -Ptarget1=/src/preprocessing/docker_result/stackOverview_2images.json -Ptarget2=/src/preprocessing/docker_result/S1A_SLC_20240811T165248_311760_IW2_VV_027360_Orb_Stack_2images
```
