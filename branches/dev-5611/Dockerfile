ARG  DOCKER_LINUX_DIST=ubuntu
ARG  DOCKER_DIST_TAG=latest 
# TODO Argument checking user need to create images only of tested distributions ...

FROM $DOCKER_LINUX_DIST:$DOCKER_DIST_TAG
MAINTAINER Modelon

COPY Docker/*.sh Docker/build/
COPY . /JModelica.org/
RUN chmod +x Docker/build/*.sh

RUN Docker/build/run_scripts.sh

#RUN chmod +x Docker/build/*.sh
#RUN Docker/build/setup_requirements.sh &&Docker/build/setup_python_packages.sh && Docker/build/setup_ipopt.sh && Docker/build/get_jmodelica.sh && Docker/build/build.sh
#RUN Docker/build/build_casadi.sh
#RUN Docker/build/cleanup.sh