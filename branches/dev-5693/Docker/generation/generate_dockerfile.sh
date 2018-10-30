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

# variables are sourced already in build system

cat <<EOF> $(dirname     "$0")/Dockerfile
ARG LINUX_DIST=${PLATFORM}
ARG DIST_VER=${DIST_VERSION}
ARG PYTHON_VER=${PYTHON_VERSION}
ARG BUILD_TARGET=${BUILD_TARGET}

# starting linux environment
FROM \$LINUX_DIST:\$DIST_VER
LABEL maintainer="Modelon AB"
#TODO add script to get rid of "if..."
RUN if [ ${PLATFORM} = "ubuntu" ]; then apt-get update && apt-get install -y make; else echo "Currently on CentOS"; fi

# cleanup
RUN echo "TODO: Add cleanup script"
EOF
