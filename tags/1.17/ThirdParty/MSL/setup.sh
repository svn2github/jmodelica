#!/bin/bash

svn co https://svn.modelica.org/projects/Modelica/tags/v3.2.1+build.4 .
svn merge --accept base -c 7479,7502,7545,7562,7573,7977,8067,8626,8652,8663 https://svn.modelica.org/projects/Modelica/trunk

rm -r .svn
rm -r ModelicaTest
rm -r ModelicaReference
rm ObsoleteModelica3.mo
