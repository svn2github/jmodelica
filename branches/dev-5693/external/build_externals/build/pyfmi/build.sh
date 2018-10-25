# source default config
. ./default_config

# source user config
if [ -e $USER_CONFIG ]; then . $USER_CONFIG; fi

# check for invalid entries
. check_configuration.sh
   
   
pyfmi_docker: docker_image, docker_environment, fmil, install-python

pyfmi: Local_environment, fmil
    python setup.py bdist_wheel --fmil-home=$FMIL_HOME

c-compiler: 
    $BUILD_ENVIRONMENT/platforms/$PLATFORM/install_gcc.sh

dockerfile:
    $DOCKER_UTILS_DIR/generation/generate_dockerfile.sh

docker_image: dockerfile
    $DOCKER_UTILS_DIR/build_docker_image.sh

docker_environment:
    $BUILD_EXTERNALS_DIR/docker/platforms/$PLATFORM/install_dependencies.sh

fmil: cmake, c-compiler
    $(cd $FMIL_HOME && cmake something)

install-python:
    $BUILD_ENVIRONMENT/platforms/$PLATFORM/install_python.sh $PYTHON_VERSION
    
local_environment:
    check_python_version.sh $PYTHON_VERSION
    
cmake:
    $BUILD_ENVIRONMENT/platforms/$PLATFORM/install_cmake.sh