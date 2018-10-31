#!make
#SHELL := /bin/bash

include default_config
export $(shell sed 's/=.*//' default_config)

include $(USER_CONFIG)
export $(shell sed 's/=.*//' $(USER_CONFIG))

#TODO add layer squashing

#TODO control environment (if using msys or git bash) 

# check for invalid entries (file does not exist yet)
#. check_configuration.sh

.EXPORT_ALL_VARIABLES:

.PHONY: docker_environment install-python c-compiler fmil pyfmi_docker dockerfile
#TODO test building docker configurations (generating different docker_id), and test that we get the correct ID

# Please see section 6.11 https://www.gnu.org/software/make/manual/make.html#Target_002dspecific
pyfmi_docker: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
pyfmi_docker: docker_image
	@echo "Starting docker with id ${DOCKER_ID}"
	@docker run -v ${PATH_TO_MOUNT}:${JM_HOME_IN_DOCKER} ${DOCKER_ID} sh -c "cd ${JM_HOME_IN_DOCKER}/external/build_externals/build/pyfmi && make pyfmi_docker_build"
	#docker run -t ${DOCKER_ID} sh -c "awk -F= '/^NAME/{print $2}' /etc/os-release"

pyfmi_docker_build: docker_environment fmil install-python python_packages
	@echo "pyfmi build placeholder"

python_packages: install-python
	${BUILD_EXTERNALS_DIR}/docker/platforms/non-specific/install_python_packages.sh
docker_environment:
	${BUILD_EXTERNALS_DIR}/docker/platforms/${PLATFORM}/install_dependencies.sh

pyfmi_wheel: LOCAL_BUILD_DIR=$(BUILD_DIR)/PYFMI_WHEELBUILD_$(BITNESS)
pyfmi_wheel:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(PYFMI_SRC)/../; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/PyFMI; \
	$(PYTHONHOME)python setup.py bdist_wheel --fmil-home=$(FMIL_HOME) $(EXTRA_SETUP_ARGS)

pyfmi_folder: LOCAL_BUILD_DIR=$(BUILD_DIR)/PYFMI_FOLDERBUILD_$(BITNESS)
pyfmi_folder: INSTALL_DIR=$(BUILD_DIR)/PYFMI_FOLDERINSTALL_$(BITNESS)
pyfmi_folder: PYTHONPATH=$(INSTALL_DIR)/Lib/site-packages
pyfmi_folder:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(PYFMI_SRC)/../; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/PyFMI; \
	mkdir -p $(INSTALL_DIR)/Lib/site-packages; \
	$(PYTHONHOME)python setup.py install --fmil-home=$(FMIL_HOME) $(EXTRA_SETUP_ARGS) --prefix=$(INSTALL_DIR); \

c-compiler:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_gcc.sh

docker_image: dockerfile
	${DOCKER_UTILS_DIR}/build_docker_image.sh ./default_config

dockerfile:
	${DOCKER_UTILS_DIR}/generation/generate_dockerfile.sh
	# TODO: use dockerfile hash or include information in dockerfile

fmil: cmake
	@echo "FMIL build placeholder"
	cd $FMIL_HOME && cmake something
	# TODO: Maybe call fmil makefile

install-python: docker_environment c-compiler
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_python.sh ${PYTHON_VERSION}

local_environment:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/check_python_version.sh ${PYTHON_VERSION}

cmake:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_cmake.sh

clean: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
clean:
	@docker rmi -f ${DOCKER_ID}
