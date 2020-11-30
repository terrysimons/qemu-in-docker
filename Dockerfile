FROM ubuntu:20.10 as developer-base
LABEL maintainer="terry.simons@gmail.com"
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && apt install -y \
    build-essential \
    clang \
    coreutils \
    curl \
    libaio-dev \
    libbluetooth-dev \
    libbz2-dev \
    libcap-dev \
    libcap-ng-dev \
    libcurl4-gnutls-dev \
    libgtk-3-dev \
    libibverbs-dev \
    libfdt-dev \
    libglib2.0-dev \
    libiscsi-dev \
    libjpeg8-dev \
    libncurses5-dev \
    libnfs-dev \
    libnuma-dev \
    libpixman-1-dev \
    librbd-dev \
    librdmacm-dev \
    libsasl2-dev \
    libsdl1.2-dev \
    libseccomp-dev \
    libsnappy-dev \
    libssh2-1-dev \
    libvde-dev \
    libvdeplug-dev \
    libvte-dev \
    libxen-dev \
    liblzo2-dev \
    lldb \
    firefox \
    git \
    git-email \
    python \
    python3 \
    qt5-default \
    strace \
    sudo \
    sysfsutils \
    unzip \
    valgrind \
    wget \
    xfslibs-dev \
    zlib1g-dev

FROM developer-base as opengl-base
RUN apt install -y \
    *epoxy* \
    libosmesa* \
    lib*gl*mesa* \
    libgbm* \
    libvulkan1 \
    mesa-utils \
    mesa-utils-extra \
    mesa-vulkan-drivers \
    vulkan-utils

FROM opengl-base as qemu-base
RUN apt install -y \
    aqemu \
    binutils-dev \
    grub-firmware-qemu \
    libqcow* \    
    libvirt* \
    libvirglrenderer-dev \
    qemu-guest-agent \
    qemu-system-* \
    qemu-user \
    sparse

# For building new QEMU:
# --enable-rdma
# https://community.mellanox.com/s/article/howto-enable--verify-and-troubleshoot-rdma#jive_content_id_For_Ubuntu_Installation
RUN apt install -y \
 rdma* \
 infiniband-diags \
 libibumad* \
 ibutils \
 ibverbs-utils \
 tgt \
 targetcli* \
 istgt \
 open-iscsi \
 libiscsi*

# --enable-membarrier
RUN apt install -y \
    liburcu*

# --enable-spice
RUN apt install -y \
    spice-* \
    libspice-*

# --enable-smartcard
RUN apt install -y \
    libcacard*

# --enable-libusb
RUN apt install -y \
    libusb*

# --enable-opengl
RUN apt install -y \
    libosmesa* \
    lib*gl*mesa* \
    *epoxy* \
    libgbm*

# --enable-gluster
RUN apt install -y \
    glusterfs* \
    libgfap* \
    libgfchange* \
    libgfrpc* \
    libgfxdr* \
    libgluster* \
    nfs-*gluster \
    uwsgi*gluster*

# --enable-libssh
#RUN apt install -y \
#    *gcrypt*

# Not working:
# --enable-lzfse
# lz*

# --enable-libxml2
run apt install -y \
    libxml2*

# Not working:
# --enable-tcmalloc
# gperf*

# --enable-jemalloc
RUN apt install -y \
    libjemalloc*

# --enable-vxhs
# ERROR: User requested feature vxhs block device
#       configure was not able to find it.
#       Install libvxhs See github

# --enable-libpmem
RUN apt install -y \
    libpmem*

FROM qemu-base as developer-local

RUN apt install -y \
    emacs \
    firefox \
    libcrypt2 \
    libgcrypt20* \
    libsdl2-* \
    libvirt-clients \
    libvirt-daemon \
    libvte* \
    nmap \
    ncat

ARG USER=developer
ENV USER=${USER}
ARG HOME=/home/${USER}
ENV HOME=${HOME}

RUN adduser --home ${HOME} --disabled-password --gecos "Developer Account" --shell /bin/bash ${USER}
RUN usermod -a -G libvirt ${USER}
RUN usermod -a -G video ${USER}
RUN echo "${USER} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

USER ${USER}
WORKDIR ${HOME}

# http://ask.xmodulo.com/install-full-kernel-source-debian-ubuntu.html
# git clone git://kernel.ubuntu.com/ubuntu/ubuntu-$(lsb_release --codename | cut -f2).git
# sudo apt-get build-dep linux-image-$(uname -r)
# RUN git clone https://github.com/luigirizzo/netmap.git
# WORKDIR ${HOME}/netmap

WORKDIR ${HOME}
ARG QEMU_VERSION=4.1.1
ARG QEMU_ROOT=qemu-${QEMU_VERSION}
ARG QEMU_TARBALL=${QEMU_ROOT}.tar.bz2
ARG QEMU_PREFIX_PATH=/usr/local
ARG QEMU_CC=clang
ARG QEMU_CXX=clang++

RUN wget https://download.qemu.org/${QEMU_TARBALL}
RUN tar xvfj ${QEMU_TARBALL}

WORKDIR ${HOME}/${QEMU_ROOT}
# Build with clang
RUN bash configure \
    --prefix=${QEMU_PREFIX} \
    --cc=${QEMU_CC} \
    --cxx=${QEMU_CXX} \
    --enable-hax \
    --enable-membarrier \
    --enable-jemalloc \
    | grep -e "no$"

#RUN make -j $(nproc) && \
#    sudo make install

# ./configure --cc=clang --cxx=clang++ --enable-hax --enable-membarrier --enable-rbd --enable-xfsctl --enable-snappy --enable-avx2

#RUN bash configure \
#    --enable-gprof \
#    --enable-sparse \
#    --enable-profiler \
#    --enable-vte \
#    --enable-hax \
#    --enable-hvf \
#    --disable-whpx \
#    --enable-tcg-interpreter \
#    --enable-rdma \
#    --enable-membarrier \
#    --enable-spice \
#    --enable-smartcard \
#    --enable-libusb \
#    --enable-opengl \
#    --enable-gcov \
#    --enable-debug

RUN sudo apt install -y \
    *canberra*

WORKDIR ${HOME}

FROM developer-local as vscode-stage

COPY keyboard-configuration.exp ${HOME}
RUN sudo apt install -y expect
RUN expect ${HOME}/keyboard-configuration.exp

RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
RUN sudo install -o root -g root -m 644 packages.microsoft.gpg /usr/share/keyrings/
RUN sudo sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'

RUN sudo apt install -y apt-transport-https
RUN sudo apt update
RUN sudo apt install -y code # or code-insiders

# Install VSCode plugins.
COPY install-vscode-extensions.sh ${HOME}/install-vscode-extensions.sh
RUN ${HOME}/install-vscode-extensions.sh

# Use the same VSCode settings as the host user.
#COPY vscode-settings ${HOME}/.vscode
#RUN sudo chown -R ${USER} ${HOME}/.vscode

RUN code --list-extensions --show-versions

FROM vscode-stage as final-stage

COPY entrypoint.sh ${HOME}/entrypoint.sh
ENTRYPOINT ["/home/developer/entrypoint.sh"]

COPY healthcheck.sh ${HOME}/healthcheck.sh
HEALTHCHECK CMD ["${HOME}/healthcheck.sh"]

