FROM nvidia/cuda:8.0-devel-ubuntu16.04

RUN apt update
RUN apt install -y gcc-4.9 g++-4.9 gdb vim automake pkg-config cmake git zlib1g-dev
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-4.9 49  --slave /usr/bin/g++ g++ /usr/bin/g++-4.9 --slave /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-4.9 --slave /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-4.9 --slave /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-4.9

LABEL description="iva dynamic/static image_pipeline build environment"

CMD ["/bin/bash"]
