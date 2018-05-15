echo "STAGE 1/4: SETUP BASE IMAGE"
echo "STAGE 2/4: ADDING JMODELICA"
. Docker/build/get_jmodelica.sh
echo "Stage 3/4: BUILDING"
. Docker/build/build.sh
echo "STAGE 4/4: BUILDING CASADI"
. Docker/build/build_casadi.sh 

echo "STAGE TESTING"
. /Docker/build/run_demo.sh 