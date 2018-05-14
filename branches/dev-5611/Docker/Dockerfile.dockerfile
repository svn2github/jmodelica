ARG  DOCKER_LINUX_DIST=ubuntu
ARG  DOCKER_DIST_TAG=latest 

# TODO Argument checking 

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon

ARG ARG_JMODELICA_BRANCH="trunk"
ENV JMODELICA_BRANCH=$ARG_JMODELICA_BRANCH

COPY Docker/*.sh Docker/build/
COPY . /JModelica.org/

RUN . ./build/setup_requirements.sh
RUN ./build/setup_python_packages.sh
RUN . ./build/setup_ipopt.sh
RUN ./build/get_jmodelica.sh
RUN ./build/build.sh
RUN ./build/build_casadi.sh
RUN ./build/cleanup.sh