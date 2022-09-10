#!/bin/bash

#set -x

HERE="$(readlink -f "$BASH_SOURCE")"
PARENT="$(dirname "$HERE")"
SCRIPT="$(basename "$HERE")"

HELP="""./$SCRIPT: <build|run> 

Actions
-------
- Build the local Docker image for the Stable Diffusion webui. 
  >>> ./$SCRIPT build
- Run the Docker container with the Stable Diffusion webui from the local Docker image.
  >>> ./$SCRIPT run
"""

ACTION="$1"	

source "$PARENT/build/build.sh"

run () {

	for i in app facexlib models; do
		mkdir -p "$PARENT/share/$i"
	done
	docker_exec run -d --gpus all \
		--name stablediffusion-webui \
		-p 7860:7860 \
		-v "$PARENT/share/app:/root/.cache" \
		-v "$PARENT/share/facexlib/:/app/src/facexlib/facexlib/weights" \
		-v "$PARENT/share/models/:/models" \
		-v "$PARENT/output:/output" \
		--env-file "$PARENT/env" \
		"$LOCAL_IMAGE"	
	echo "Please watch the logs with 'docker logs -f stablediffusion-webui'."
}

if [ "$ACTION" == "build" ]; then
	build 
elif [ "$ACTION" == "run" ]; then
	run
else
	echo "$HELP"
	exit 1 
fi

