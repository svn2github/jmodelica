FROM centos:6.7
MAINTAINER Modelon

ARG ARG_JMODELICA_BRANCH=trunk
ENV JMODELICA_BRANCH=$ARG_JMODELICA_BRANCH;

COPY *.sh /build/

RUN ./build/setup_requirements.sh
RUN ./build/setup_python_packages.sh
RUN ./build/setup_ipopt.sh
RUN ./build/get_jmodelica.sh
RUN ./build/build.sh
RUN ./build/build_casadi.sh
RUN ./build/cleanup.sh