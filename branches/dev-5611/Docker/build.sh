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

. /Docker/build/settings.sh

cd JModelica.org
mkdir build
cd build

#TODO we probably need change these PWD later? Or at least investigate if paths are saved in configured docker image


../configure --prefix=${HOME}/jm_install --with-ipopt=${IPOPT_INSTALLATION_LOCATION} || exit $?
make install || exit $?
cd ../..
env 