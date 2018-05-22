ARG DOCKER_LINUX_DIST=ubuntu
ARG DOCKER_DIST_TAG=latest

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon


COPY Docker/*.sh ${USR_PATH}/Docker/build/
RUN chmod +x ${USR_PATH}/Docker/build/*.sh
RUN ${USR_PATH}/Docker/build/run_base_scripts.sh