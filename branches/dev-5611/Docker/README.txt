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

For the latest version of Ubuntu, navigate to the folder with the Dockerfile, and run:

docker build -f ./Dockerfile_full_image . --build-arg DOCKER_LINUX_DIST=jmodelica/ubuntu_base --build-arg DOCKER_DIST_TAG=18.04 .

For the CentOS version 7.3, run:

docker build -f ./Dockerfile_full_image . --build-arg DOCKER_LINUX_DIST=jmodelica/centos_base --build-arg DOCKER_DIST_TAG=7.3 .

Available environment variables: 

DOCKER_LINUX_DIST=<linux-distribution> 
DOCKER_DIST_TAG=<distribution-release> 

After building, you can for example list all the installed packages (for the ubuntu image) with the following command: 
docker run -it jmodelica/ubuntu_base:18.04 apt list --installed

to instantiate a container of the resulting image, try

> docker image ls 
> docker run -v C:/path/to/shared/folder/:/shared -it  --name jm-<os>-<tag> <image-id>