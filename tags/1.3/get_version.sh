#!/bin/bash
DIR="$(svn info $1 | sed -n 's_URL: https://svn.jmodelica.org/\(.*\)$_\1_p')"
TYPE="$(echo ${DIR} | cut -d/ -f1)"
case ${TYPE} in
    branches|tags)
        echo ${DIR} | cut -d/ -f2
        ;;
    trunk)
        svnversion $1 | sed -e 's/^.*://' -e 's/[^0-9]*//g' -e 's/^/r/'
        ;;
    *)
        echo unknown
        ;;
esac
