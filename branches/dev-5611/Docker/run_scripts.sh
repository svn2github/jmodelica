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