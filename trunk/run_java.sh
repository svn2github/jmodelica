#!/bin/bash
# This script must not be in $PATH!
# Relative path from this script to source dir.
REL=.
# Path to source dir (relative to cwd or absolute depending on $0)
SRC=$(dirname $0)/${REL}
CLS=$1

shift
FILE=${SRC}/Compiler/ModelicaFrontEnd/src/java/${CLS//.//}.java
TEMP=$(mktemp -dqt)
javac -d ${TEMP} ${FILE}
java -cp ${TEMP} ${CLS} $@
rm -rf ${TEMP}
