#!/bin/bash

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <docker_username> <docker_image_name> <version> <path_to_dockerfile>"
    exit 1
fi

DOCKER_USERNAME="$1"
DOCKER_IMAGE_NAME="$2"
VERSION="$3"
DOCKERFILE_PATH="$4"
IMAGE="$DOCKER_USERNAME/$DOCKER_IMAGE_NAME:$VERSION"

docker build -t "$IMAGE" "$DOCKERFILE_PATH" --no-cache
docker login --username "$DOCKER_USERNAME" --password "Niceday32"
docker push "$IMAGE"


echo "************** IMAGE: $IMAGE has been published"