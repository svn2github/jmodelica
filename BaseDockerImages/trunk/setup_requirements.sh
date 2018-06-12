#!/bin/sh
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

BUILD_PKGS_JM_COMMON="vim sudo cmake swig ant wget tar patch"
BUILD_PKGS_JM_REDHAT="redhat-lsb ant-junit dos2unix python-pip bc make lucene which subversion gcc-c++ gcc-gfortran python-ipython java-1.8.0-openjdk python-devel scipy python-matplotlib Cython python-nose python-jpype zlib-devel boost-devel"
BUILD_PKGS_JM_DEBIAN="dos2unix dc jcc python-lucene subversion g++ gfortran ipython openjdk-8-jdk python-dev python-scipy cython python-nose python-jpype zlib1g-dev libboost-dev"

BUILD_PYTHON_PIP_PACKAGES="jupyter colorama nbformat Jinja2 openpyxl mock natsort six MarkupSafe lxml==4.2.1 numpy=1.14.4"

if [ "$LINUX_DISTRIBUTION" = "CENTOS" ]; then
	BUILD_PKGS_JM=$BUILD_PKGS_JM_REDHAT
	yum -y install epel-release  # for some python packages 
	alias pckinstall="yum -y install"
elif [ "$LINUX_DISTRIBUTION" = "REDHAT" ]; then
	BUILD_PKGS_JM=$BUILD_PKGS_JM_REDHAT
	yum -y install epel-release  # for some python packages 
	alias pckinstall="yum -y install"
elif [ "$LINUX_DISTRIBUTION" = "DEBIAN" ]; then 
	BUILD_PKGS_JM=$BUILD_PKGS_JM_DEBIAN
	apt-get update
    apt-get -y install tzdata #install separately due to issues with backends in docker
	alias pckinstall="apt-get -y install"
else 
	echo ERROR: current linux distribution not supported yet
    exit 1
fi

pckinstall $BUILD_PKGS_JM_COMMON
pckinstall $BUILD_PKGS_JM

if [ "$LINUX_DISTRIBUTION" = "CENTOS" ]; then
    echo "Installing extra python packages with pip on CentOS"
	pip install $BUILD_PYTHON_PIP_PACKAGES
elif [ "$LINUX_DISTRIBUTION" = "DEBIAN" ]; then
    echo "Installing extra packages for Ubuntu"
    #Install package lsb separately because it conflicts with the installation above
    apt-get -y install lsb python3-notebook jupyter-core python-ipykernel
    echo "Installing extra python packages with pip on Ubuntu"
    pip install $BUILD_PYTHON_PIP_PACKAGES
    pip install matplotlib==2.0.2 #due to issues with ImportError: No module named functools_lru_cache
fi
