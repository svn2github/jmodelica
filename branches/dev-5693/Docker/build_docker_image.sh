#!/bin/bash
# 
#    Copyright (C) 2018 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.

BASE_DIR=$(dirname "$0")
CONFIG=$1
USER_CONFIG=$2
TAG_NAME=$3
DOCKERFILE_DIR=$4
OVERRIDE_TARGET=$5

echo "Building docker image..."
echo -e "\tusing CONFIG $CONFIG USER_CONFIG $USER_CONFIG and TAG_NAME $TAG_NAME"
echo -e "\tCurrent working directory is ${PWD} with contents: "
ls -la

[[ -e "$CONFIG" ]] && source $CONFIG || echo "build_docker_image: No such config $CONFIG"
[[ -e "$USER_CONFIG" ]] && source $USER_CONFIG || echo "build_docker_image: No such user config $USER_CONFIG"


# check if docker image with given config already exists
HASH_GEN_TAG="$(echo -n $PLATFORM $DIST_VERSION $BUILD_TARGET $PYTHON_VERSION $OVERRIDE_TARGET | md5sum | awk '{print $1}')"

# build image if not found among images
if ! docker images | grep -q "$HASH_GEN_TAG" ; then
    mkdir -p $DOCKERFILE_DIR
    cp $BASE_DIR/generation/Dockerfile $DOCKERFILE_DIR
    docker build -t "${TAG_NAME}:${HASH_GEN_TAG}" -f $DOCKERFILE_DIR/Dockerfile .
fi
DOCKER_ID=$(docker images | grep "$HASH_GEN_TAG" | awk '{print $3}')