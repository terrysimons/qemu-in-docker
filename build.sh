#!/usr/bin/env bash
# https://vaneyckt.io/posts/safer_bash_scripts_with_set_euxo_pipefail/
set -Eeuxo pipefail

# TODO: Add option for latest VSCode plugins.
# TODO: Add option to copy VSCode settings.

IMAGE_NAME=qemu-in-docker
CONTAINER_NAME=${IMAGE_NAME}
ARCH=$(arch)

#       --device /dev/dri:/dev/dri \
#       --device /dev/kvm:/dev/kvm \
#       --device /dev/vfio/vfio:/dev/vfio/vfio \
#       --device /dev/vhost-net:/dev/vhost-net \
#       --device /dev/net/tun:/dev/net/tun \

DOCKER_DEVICES=" \
"

DOCKER_VOLUMES="" 
#\
#        --volume /tmp/.X11-unix:/tmp/.X11-unix \
#        --volume ${HOME}/fuchsia:/home/developer/fuchsia \
#        --volume ${HOME}/qemu:/home/developer/qemu \
#        --volume ${HOME}/.vscode:/home/developer/.vscode
# "

set +e
docker container stop ${CONTAINER_NAME}
docker container rm ${CONTAINER_NAME}
set -e

# Stage VSCode settings.
#cp -Rf ~/.vscode vscode-settings

# Create custom VSCode extension intall script.
#
# This pins the Docker extension version to the
# same versions as the Docker host.
# VSCODE_EXTENSIONS=($(code --list-extensions --show-versions))

# cat << EOF > install-vscode-extensions.sh
# #!/usr/bin/env bash
# set -Eeuxo pipefail

# EOF

# for VSCODE_EXTENSION in ${VSCODE_EXTENSIONS[@]}
# do
#     cat << EOF >> install-vscode-extensions.sh
# code --install-extension ${VSCODE_EXTENSION}
# EOF
# done

docker build -t ${IMAGE_NAME} -f Dockerfile-${ARCH} .
docker container create \
       -e DISPLAY=$DISPLAY \
       ${DOCKER_DEVICES} \
       ${DOCKER_VOLUMES} \
       --name ${CONTAINER_NAME} ${IMAGE_NAME}

docker container start ${CONTAINER_NAME}
docker logs ${CONTAINER_NAME}
docker container exec --privileged -it ${CONTAINER_NAME} /bin/bash

