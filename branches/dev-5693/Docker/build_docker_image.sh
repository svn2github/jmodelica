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
CONFIG="${BASE_DIR}/configurations/docker_config"
. "${CONFIG}"

# check if docker image with given config already exists
HASH_GEN_TAG="$(echo -n $LINUX_DIST $DIST_VER $PYTHON_VER $BUILD_TARGET | md5sum | awk '{print $1}')"
if docker images | grep -q "$HASH_GEN_TAG"; then
    DOCKER_IMAGE_EXISTS=1
else
    DOCKER_IMAGE_FALSE=0
fi

if [ "$DOCKER_IMAGE_EXISTS" = "1" ]; then
    echo "Image already exists, please refer to image with tag ${HASH_GEN_TAG}"
else
    echo "Creating new image"
    PLATFORM_DIR="${BASE_DIR}/platforms/${LINUX_DIST}"
    CONFIG_DIR="${BASE_DIR}/configurations"
    . ${BASE_DIR}/generate_dockerfile.sh ${CONFIG} ${CONFIG_DIR} ${PLATFORM_DIR}
    docker build -t "${LINUX_DIST}:${HASH_GEN_TAG}" --no-cache .
    echo "Built image with target ${BUILD_TARGET}"
    DOCKER_ID=$(docker images | grep "$HASH_GEN_TAG" | awk "{print $3}")
    printf "Tag: ${HASH_GEN_TAG}\nId: ${DOCKER_ID}"
fi
