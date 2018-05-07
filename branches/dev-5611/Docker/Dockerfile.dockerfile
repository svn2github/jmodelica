FROM centos:6.7
MAINTAINER Modelon
COPY *.sh /build/

RUN ./build/prepare.sh
#RUN ./build/jmodelica.sh
#RUN ./build/cleanup.sh
#RUN rm -rf /build

#ENV USER root

#RUN mkdir /root/work
#WORKDIR /root/work

#CMD ["/opt/jmodelica/bin/jm_ipython.sh"]