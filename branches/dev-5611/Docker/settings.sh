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

find_os() { 

	if [ -f /etc/centos-release ]; then
		return CENTOS
	elif [ -f /etc/redhat-release ]; then 
		return REDHAT
	elif [ -f /etc/debian_version ]; then 
		return DEBIAN
	else 
		return UNKNOWN 
	fi

} 

find_os
export LINUX_DISTRIBUTION=$?
if [ "$LINUX_DISTRIBUTION" == "DEBIAN" ]; then 
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/lib/jvm/java-8-openjdk-amd64/jre/lib/amd64/server/
fi 

# IPOPT 

export IPOPT_VERSION=3.12.8
export IPOPT_LOCATION=/IPOPT_${IPOPT_VERSION}
export IPOPT_INSTALLATION_LOCATION=${IPOPT_LOCATION}/install/
