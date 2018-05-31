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

By running the Dockerfile, a base image for JModelica is built, i.e. an 
image containing necessities to make a full installation of JModelica.

Currently this build only supports Ubuntu 18.04 and CentOS 7.4 (7.4.1708).

To run the Dockerfile you need to install Docker, then, by navigating to 
the folder with the Dockerfile, the image is built by writing in a console window

docker build -f ./Dockerfile .

The image can also be built on Jenkins using a host machine that 
has the Docker plugin installed by using the Jenkinsfile. Note that 
you might have to do some changes to the Jenkinsfile depending on your setup.