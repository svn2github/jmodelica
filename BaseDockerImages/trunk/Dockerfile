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

ARG DOCKER_LINUX_DIST=ubuntu
ARG DOCKER_DIST_TAG=18.04

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon

ARG DOCKER_USR_PATH=/home/baseuser
ENV USR_PATH=${DOCKER_USR_PATH}

COPY *.sh ${USR_PATH}/Docker/build/
RUN chmod +x ${USR_PATH}/Docker/build/*.sh

RUN useradd baseuser && groupadd docker && usermod -aG docker baseuser && chown -R baseuser /
USER baseuser

RUN ${USR_PATH}/Docker/build/setup.sh
