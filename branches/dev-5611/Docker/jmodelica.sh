#! /usr/bin/env sh

NP=$(grep -c ^processor /proc/cpuinfo)

IPOPT=Ipopt-3.12.8
cd /build
wget http://www.coin-or.org/download/source/Ipopt/${IPOPT}.tgz
tar xf ${IPOPT}.tgz
for module in Blas Lapack Mumps Metis; do
  cd /build/${IPOPT}/ThirdParty/${module}
  ./get.${module}
done
cd /build/${IPOPT}
mkdir /opt/ipopt
./configure --prefix=/opt/ipopt && make -j${NP} install

mkdir /opt/jmodelica
svn co https://svn.jmodelica.org/tags/2.1 /build/jmodelica
mkdir /build/jmodelica/build
cd /build/jmodelica/build
../configure --prefix=/opt/jmodelica --with-ipopt=/opt/ipopt && make -j${NP} install && make -j${NP} casadi_interface