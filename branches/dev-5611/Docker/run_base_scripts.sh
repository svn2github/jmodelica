echo "STAGE 1/3: SETTING UP REQUIREMENTS"
. Docker/build/setup_requirements.sh
echo "STAGE 2/3: SETTING UP PYTHON PACKAGES"
. Docker/build/setup_python_packages.sh
echo "STAGE 3/3: SETTING UP IPOPT"
. Docker/build/setup_ipopt.sh