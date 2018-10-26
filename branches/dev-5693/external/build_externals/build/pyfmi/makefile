# source default config
. ./default_config

# source user config
if [ -e $USER_CONFIG ]; then . $USER_CONFIG; fi

# check for invalid entries (file does not exist yet)
#. check_configuration.sh

# note in makefile we need to have a tab and not a tab replaced by spaces

pyfmi_docker: docker_image
	$(docker run -it -v $JM_HOME:$JM_HOME_DOCKER $DOCKER_ID sh -c $JM_HOME_DOCKER/external/build_externals/build/pyfmi/make "pyfmi_docker_build")


pyfmi_docker_build: docker_environment, fmil, install-python
	$(python setup.py bdist_wheel --fmil-home=$FMIL_HOME)

pyfmi:
	$(python setup.py bdist_wheel --fmil-home=$FMIL_HOME)

c-compiler: 
	$BUILD_ENVIRONMENT/platforms/$PLATFORM/install_gcc.sh

dockerfile:
	$DOCKER_UTILS_DIR/generation/generate_dockerfile.sh

docker_image: dockerfile
	$DOCKER_UTILS_DIR/build_docker_image.sh

docker_environment:
	$BUILD_EXTERNALS_DIR/docker/platforms/$PLATFORM/install_dependencies.sh

fmil: cmake
	$(cd $FMIL_HOME && cmake something)

install-python: c-compiler
	$BUILD_ENVIRONMENT/platforms/$PLATFORM/install_python.sh $PYTHON_VERSION

local_environment:
	$BUILD_ENVIRONMENT/platforms/$PLATFORM/check_python_version.sh $PYTHON_VERSION

cmake:
	$BUILD_ENVIRONMENT/platforms/$PLATFORM/install_cmake.sh
