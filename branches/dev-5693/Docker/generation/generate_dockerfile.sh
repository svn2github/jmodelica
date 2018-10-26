#!/bin/sh
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

cat <<EOF> $(dirname "$0")/Dockerfile
ARG LINUX_DIST=${PLATFORM}
ARG DIST_VER=${DIST_VERSION}
ARG PYTHON_VER=${PYTHON_VERSION}
ARG BUILD_TARGET=${BUILD_TARGET}

# starting linux environment
FROM \$LINUX_DIST:\$DIST_VER
LABEL maintainer="Modelon AB"

# directory to put build scripts
ENV BUILD_DIR=/tmp/build_scripts

# copy or (svn checkout) build scripts to directory (docker doesnt allow COPY dir)
#RUN mkdir -p \${BUILD_DIR} \${BUILD_DIR}/configurations
#RUN mkdir -p \${BUILD_DIR}/platforms/\${LINUX_DIST} \${BUILD_DIR}/platforms/non-specific
#COPY build.sh \${BUILD_DIR}
#COPY ${PLATFORM_DIR} \${BUILD_DIR}/platforms/\${LINUX_DIST}
#COPY ${CONFIG_DIR} \${BUILD_DIR}/configurations

# fix executive rights on all shell scripts
#RUN chmod -R +x \${BUILD_DIR}/*.sh

# run build
#RUN build.sh inputarguments
#RUN echo "Installing requirements && \${BUILD_DIR}/docker_setup.sh "\${BUILD_DIR}/configurations/docker_config"
#RUN echo "Installing Python" && ${BUILD_DIR}/platforms/${LINUX_DIST}/install_python.sh ${PYTHON_VER}

# cleanup
RUN echo "TODO: Add cleanup script"
EOF

TODO: Fix COPY since it DOES NOT COPY TOP LEVEL