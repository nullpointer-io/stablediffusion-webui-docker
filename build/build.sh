#!/bin/bash

#set -x

HERE="$(dirname "$(readlink -f "$BASH_SOURCE")")"

LOCAL_IMAGE='stable-diffusion-webui'

can_sudo () {
        sudo_response=$(SUDO_ASKPASS=/bin/false sudo -A whoami 2>&1 | wc -l)
        if [ $sudo_response = 2 ]; then
            return 0
        elif [ $sudo_response = 1 ]; then
            return 1
        else
            echo "Unexpected sudo response: $sudo_response" >&2
            exit 1
        fi
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