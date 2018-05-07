FROM centos:6.7
MAINTAINER Modelon
COPY *.sh /build/

RUN ./build/setup_requirements.sh
RUN ./build/setup_python_packages.sh
RUN ./build/setup_ipopt.sh
RUN ./build/build.sh
RUN ./build/build_casadi.sh
Run ./build/cleanup.sh