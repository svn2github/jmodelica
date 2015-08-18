#!/bin/bash

svn co https://svn.modelica.org/projects/Modelica/tags/v3.2.1+build.3 .
svn merge --accept base -c 7502,7545,7977,7573,7479 https://svn.modelica.org/projects/Modelica/trunk

rm -r .svn
rm -r ModelicaTest
rm -r ModelicaReference
rm ObsoleteModelica3.mo
#rm Modelica/StateGraph.mo
#rm Modelica/Electrical/Digital.mo
#rm Modelica/Electrical/Machines.mo
#rm -r Modelica/Electrical/QuasiStationary
#rm -r Modelica/Fluid
