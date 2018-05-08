Building 
========

For the latest version of Ubunto: 

> docker build -t jmodelica/ubuntu:0.1  --build-arg  DOCKER_LINUX_DIST=ubuntu -f  Dockerfile.dockerfile . 

DOCKER_LINUX_DIST=<linux-distribution> 
DOCKER_DIST_TAG<distribution-release> 
DOCKER_JMODELICA_BRANCH=<jmodelica-branch> 