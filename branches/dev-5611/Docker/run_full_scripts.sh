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
. $1/Docker/build/settings.sh
echo "ECHO OF USR_PATH"
echo ${USR_PATH}
echo "PWD is here"
echo $PWD
cd home
ls -la
cd jenkins
ls -la
echo "STAGE 0/3: FILES IN BUILD FOLDER"
ls -la ${USR_PATH}/Docker/build
echo "STAGE 1/3: ADDING ASSIMULO"
. /home/jenkins/Docker/build/get_assimulo.sh
echo "Stage 2/3: BUILDING"
. ${USR_PATH}Docker/build/build.sh
echo "STAGE 3/3: SKIPPED BUILDING CASADI"
# . ${USR_PATH}Docker/build/build_casadi.sh 
