ARG DOCKER_LINUX_DIST=ubuntu
ARG DOCKER_DIST_TAG=18.04

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon

ARG DOCKER_USR_PATH=/home/jenkins
ENV USR_PATH=${DOCKER_USR_PATH}

COPY Docker/*.sh ${USR_PATH}/Docker/build/
RUN chmod +x ${USR_PATH}/Docker/build/*.sh
RUN ${USR_PATH}/Docker/build/run_base_scripts.sh