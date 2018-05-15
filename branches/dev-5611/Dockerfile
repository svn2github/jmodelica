ARG DOCKER_LINUX_DIST=ubuntu
ARG DOCKER_DIST_TAG=latest

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon

COPY Docker/*.sh Docker/build/
RUN chmod +x Docker/build/*.sh
RUN Docker/build/run_scripts.sh