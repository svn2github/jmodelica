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

echo "STAGE 1/6: SETTING UP REQUIREMENTS"
. Docker/build/setup_requirements.sh
echo "STAGE 2/6: SETTING UP PYTHON PACKAGES"
. Docker/build/setup_python_packages.sh
echo "STAGE 3/6: SETTING UP IPOPT"
. Docker/build/setup_ipopt.sh
echo "STAGE 4/6: ADDING JMODELICA"
. Docker/build/get_jmodelica.sh
echo "Stage 5/6: BUILDING"
. Docker/build/build.sh
echo "STAGE 6/6: BUILDING CASADI"
. Docker/build/build_casadi.sh 

echo "STAGE TESTING"
. /Docker/build/run_demo.sh 