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

set -e

. ${USR_PATH}/Docker/build/settings.sh 

INSTALL_TYPE=$1

echo "INSTALL_TYPE=$INSTALL_TYPE"

if [ "$INSTALL_TYPE" = "CENTOS7_GCC" ]
then
    yum install -y gcc-c++ gcc-gfortran
elif [ "$INSTALL_TYPE" = "CENTOS6_GCC" ]
then
    yum install -y wget

    # Install gcc 4.8.2
    wget --no-check-certificate -O /etc/yum.repos.d/slc6-devtoolset.repo https://linuxsoft.cern.ch/cern/devtoolset/slc6-devtoolset.repo
    sed -i 's/gpgcheck=1/gpgcheck=0/g' /etc/yum.repos.d/slc6-devtoolset.repo
    yum install -y devtoolset-2-toolchain.noarch

    # Install x86 support for gcc 4.8.2
    yum install -y devtoolset-2-li‌‌bquadmath-devel.i686 devtoolset-2-libstdc++-devel.i686 devtoolset-2-memstomp.i686
    # Enable the environment
    scl enable devtoolset-2 bash
elif [ "$INSTALL_TYPE" = "UBUNTU_GCC" ]
then
    apt get -y install g++ gfortran
else
    echo "NO VALID GCC INSTALLATION TYPE SPECIFIED, GOT INSTALL_TYPE="$INSTALL_TYPE
    false
fi
