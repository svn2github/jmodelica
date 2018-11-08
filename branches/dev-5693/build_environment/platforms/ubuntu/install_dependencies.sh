#!/bin/sh

set -e

apt-get clean
apt-get update

echo "[install_dependencies]: Installing dependencies on Ubuntu"

apt-get install -y g++
apt-get install -y --no-install-recommends apt-utils dialog # to fix docker issues, perhaps add --no-install-recommends 

#apt-get install -y --no-install-recommends libssl-dev zlib1g-dev libbz2-dev libsqlite3-dev # for python installations
#apt-get install -y --no-install-recommends build-essential # for a C-compiler, needed to build Python
#apt-get install -y --no-install-recommends wget # only needed when building python from source

echo -e "\tFinished installing dependencies on Ubuntu"

echo -e "\tRunning ln -s /usr/bin/make /usr/bin/gmake"
ln -s /usr/bin/make /usr/bin/gmake