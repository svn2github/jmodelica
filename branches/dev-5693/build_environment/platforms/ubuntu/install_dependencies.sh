#!/bin/sh

set -e

apt-get clean
apt-get update
apt-get install -y --no-install-recommends apt-utils dialog # to fix docker issues, perhaps add --no-install-recommends 
apt-get install -y --no-install-recommends libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev # for python installations
apt-get install -y --no-install-recommends build-essential # for a C-compiler, needed to build Python
apt-get install -y --no-install-recommends wget

#for centos
#yum install zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel
