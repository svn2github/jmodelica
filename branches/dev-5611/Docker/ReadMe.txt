# 
#    Copyright (C) 2018 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.

Building 
========

For the latest version of Ubunto: 

> docker build -t jmodelica/ubuntu:0.1  --build-arg  DOCKER_LINUX_DIST=ubuntu -f  <dockerfile-name> . 

Available dockerfiles are 
- Dockerfile.all : build a JModelica image from scratch 
- Dockerfile : build a base image for JModelica 
- Dockerfile : build JModelica image based on a base image 

Available environment variables: 

DOCKER_LINUX_DIST=<linux-distribution> 
DOCKER_DIST_TAG=<distribution-release> 
DOCKER_JMODELICA_BRANCH=<jmodelica-branch> 

A JModelica tagged version can be also choosen by using --build-arg DOCKER_JMODELICA_BRANCH=</tags/tag-version>

Example of a build command: 
> docker build -t jmodelica/centos7.3:0.1  --build-arg  DOCKER_LINUX_DIST=centos --build-arg DOCKER_DIST_TAG=7.3 -f  Dockerfile.all .

to instantiate a container of the resulting image, try

> docker image ls 
> docker run -v C:/path/to/shared/folder/:/shared -it  --name jm-<os>-<tag> <image-id>