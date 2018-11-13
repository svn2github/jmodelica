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

source $1
[[ -e $2 ]] && source $2
OVERRIDE_TARGET=$3
HASH_GEN_TAG="$(echo -n $PLATFORM $DIST_VERSION $BUILD_TARGET $OVERRIDE_TARGET | md5sum | awk '{print $1}')"
DOCKER_ID=$(docker images | grep "$HASH_GEN_TAG" | awk '{print $3}')
echo "${DOCKER_ID}"