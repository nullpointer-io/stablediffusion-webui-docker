#!/bin/bash

#set -x

HERE="$(dirname "$(readlink -f "$BASH_SOURCE")")"

LOCAL_IMAGE='stablediffusion-webui'

can_sudo () {
    sudo_response=$(SUDO_ASKPASS=/bin/false sudo -A whoami 2>&1 | wc -l)
    if [ "$sudo_response" == "$(whoami)" ]; then
        return 0
    fi
    return 1
}

docker_exec () {
    local params="$@"
    local DOCKER_EXEC=docker	
    if ! $DOCKER_EXEC info &>/dev/null; then
	can_sudo && DOCKER_EXEC='sudo docker'
	if ! $DOCKER_EXEC info &>/dev/null; then
	    echo "Cannot execute 'docker' or 'sudo docker'. Please ensure the correct setup."
	    exit 1
	fi 
    fi
$DOCKER_EXEC $params
}

build () {
    docker_exec build -t "$LOCAL_IMAGE" "$HERE"
}
