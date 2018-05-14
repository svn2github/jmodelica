ARG  DOCKER_LINUX_DIST=ubuntu
ARG  DOCKER_DIST_TAG=latest 
# TODO Argument checking user need to create images only of tested distributions ...

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon

COPY JModelica/Docker/*.sh Docker/build/
COPY JModelica /JModelica.org/

RUN ls -la Docker/build
RUN chmod +x Docker/build/*.sh
RUN . Docker/build/setup_requirements.sh
RUN Docker/build/setup_python_packages.sh
RUN . Docker/build/setup_ipopt.sh
RUN Docker/build/get_jmodelica.sh
RUN Docker/build/build.sh
RUN Docker/build/build_casadi.sh
RUN Docker/build/cleanup.sh