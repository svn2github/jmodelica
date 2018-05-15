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

. /Docker/build/ipopt_settings.sh 

wget https://www.coin-or.org/download/source/Ipopt/Ipopt-${IPOPT_VERSION}.tgz

CURRDIR=$PWD 
tar xvf Ipopt-${IPOPT_VERSION}.tgz
cd Ipopt-${IPOPT_VERSION}/ThirdParty/Blas
./get.Blas
cd ../Lapack
./get.Lapack
cd ../Mumps
./get.Mumps
cd ../Metis
./get.Metis
cd ../..

mkdir build
cd build
#Test with absolute path due to errors
mkdir ipopt-installation

IPOPT_INSTALLATION_LOCATION="$PWD"/ipopt-installation
export IPOPT_INSTALLATION_LOCATION

../configure --prefix=${IPOPT_INSTALLATION_LOCATION}
make install
cd $CURRDIR
env 