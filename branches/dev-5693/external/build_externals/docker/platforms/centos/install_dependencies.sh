#!/bin/sh

set -e


# package needed for some python packages and usually causes issues when not installed separately
yum -y install epel-release
# might need more (or less)
yum -y install zlib-devel bzip2-devel sqlite sqlite-devel openssl-devel
