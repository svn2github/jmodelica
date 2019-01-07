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

# find Java location containing jni.h, variable JCC_JDK needs to be set to install jcc
# also grep for 1.8.0 in case we find multiple versions
export JCC_JDK=$(find /usr -type f -name "jni.h" | cut -d '/' -f-5 | grep "1.8.0")

lines=$(echo $JCC_JDK | wc -l)
if [ $lines -eq 0 ];
then
    echo -e "\e[31m" "setup_jcc: Could not find jni.h" "\e[0m"
    exit 1
fi

pip install jcc==2.23

JCC_INSTALL_DIR=$(find /usr -type d -name jcc)
cp ${USR_PATH}/Docker/build/jcc.patch ${JCC_INSTALL_DIR}
cd ${JCC_INSTALL_DIR}
patch < jcc.patch

rm jcc.patch