#!/bin/bash

set -e

PYTHON_VER=$1
# If we install python version X.Y.Z we get directory pythonX.Y, so we extract first two digits
SHORT_VER=${PYTHON_VER:0:3}

# build python 
URL="https://www.python.org/ftp/python/${PYTHON_VER}/Python-${PYTHON_VER}.tgz"
cd /usr/src/
echo "Trying to access ${URL}"
wget "${URL}"
if [[ "$?" != 0 ]]; then
    echo "Error downloading Python ${PYTHON_VER}"
    exit 1
else
    echo "Successfully downloaded Python ${PYTHON_VER}"
fi
tar xzf Python-${PYTHON_VER}.tgz
cd Python-${PYTHON_VER}

#TODO check configure installation path
./configure
make altinstall
python${SHORT_VER} --version
echo "alias python=python${SHORT_VER}" >> ~/.bashrc
source ~/.bashrc