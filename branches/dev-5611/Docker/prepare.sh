#! /usr/bin/env sh

. /build/config.sh

yum update
yum --enablerepo=extras install -y epel-release
yum install -y python-pip
pip install ${BUILD_PKGS}