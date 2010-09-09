#!/bin/bash
# This script must not be in $PATH!
# Relative path from this script to source dir.
REL=.
# Path to source dir (relative to cwd or absolute depending on $0)
SRC=$(dirname $0)/${REL}

FILE=${SRC}/Compiler/ModelicaFrontEnd/src/java/org/jmodelica/util/GetJavaHome.java
TEMP=$(mktemp -dqt)
javac -d ${TEMP} ${FILE}
java -cp ${TEMP} org.jmodelica.util.GetJavaHome
rm -rf ${TEMP}
