#
#	Copyright (C) 2018 Modelon AB
#
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License version 3 as published 
#	by the Free Software Foundation, or optionally, under the terms of the 
#	Common Public License version 1.0 as published by IBM.
#
#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License, or the Common Public License, for more details.
#
#	You should have received copies of the GNU General Public License
#	and the Common Public License along with this program.  If not, 
#	see <http://www.gnu.org/licenses/> or 
#	<http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.

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

.PHONY: docker_environment install-python c-compiler fmil pyfmi_docker dockerfile pyfmi_folder pyfmi_wheel
#TODO test building docker configurations (generating different docker_id), and test that we get the correct ID

#TODOTRY OVERRIDE JM_HOME FROM PYFMI_BASE_IMAGE SUCH THAT WE DONT NEED ANY EXTERNAL DOCKER PATHS
export FMIL_INSTALL_DIR=$(JM_HOME)/fmil_install

pyfmi_base_image: make_fmil_docker
	cd $(JM_HOME) && \
	${DOCKER_UTILS_DIR}/generation/generate_dockerfile.sh "PYFMI_BASE" && \
	${DOCKER_UTILS_DIR}/build_docker_image.sh
	@echo "Finished building pyfmi base image"

# mount, RUN install_python.sh in new docker
make_fmil_docker:
	cd $(BUILD_EXTERNALS_DIR_LOCAL)/build/fmil && make fmil_docker FMIL_INSTALL=$(FMIL_INSTALL_DIR)
	cd $(FMIL_BIN)

# Please see section 6.11 https://www.gnu.org/software/make/manual/make.html#Target_002dspecific
pyfmi_docker: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
pyfmi_docker: docker_image
	@echo "Starting docker with id ${DOCKER_ID}"
	@docker run -v ${PATH_TO_MOUNT}:${JM_HOME_IN_DOCKER} ${DOCKER_ID} sh -c "cd ${JM_HOME_IN_DOCKER}/external/build_externals/build/pyfmi && make pyfmi_docker_build"
	@docker run -v ${PATH_TO_MOUNT}:${JM_HOME_IN_DOCKER} ${DOCKER_ID} sh -c "command 2"
	#@docker rmi -f ${DOCKER_ID}

pyfmi_docker_build: docker_environment cmake fmil install-python python_packages
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
	$(PYTHONHOME)python setup.py bdist_wheel --fmil-home=$(FMIL_INSTALL) $(EXTRA_SETUP_ARGS); \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type f -name PyFMI*.whl -exec cp {} $(INSTALL_DIR_FOLDER) \;

pyfmi_folder: LOCAL_BUILD_DIR=$(BUILD_DIR)/PYFMI_FOLDERBUILD_$(BITNESS)
pyfmi_folder: LOCAL_INSTALL_DIR=$(BUILD_DIR)/PYFMI_FOLDERINSTALL_$(BITNESS)
pyfmi_folder: PYTHONPATH=$(LOCAL_INSTALL_DIR)/Lib/site-packages
pyfmi_folder:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(PYFMI_SRC)/../; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/PyFMI; \
	mkdir -p $(LOCAL_INSTALL_DIR)/Lib/site-packages; \
	$(PYTHONHOME)python setup.py install --fmil-home=$(FMIL_INSTALL) $(EXTRA_SETUP_ARGS) --prefix=$(LOCAL_INSTALL_DIR); \
	cd $(LOCAL_INSTALL_DIR)/Lib/site-packages; \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type d -name pyfmi -exec cp -r {} $(INSTALL_DIR_FOLDER) \;

c-compiler:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_gcc.sh

docker_image: dockerfile
	${DOCKER_UTILS_DIR}/build_docker_image.sh ./default_config

dockerfile:
	${DOCKER_UTILS_DIR}/generation/generate_dockerfile.sh

# TODO: Ask Agnes why we have to cd then run make, instead of running make from here
fmil: 
	cd $(BUILD_EXTERNALS_DIR)/build/fmil; \
	make install BUILD_EXTERNALS_DIR=$(BUILD_EXTERNALS_DIR) FMIL_INSTALL=$(FMIL_INSTALL) BUILD_DIR=$(BUILD_DIR) USER_CONFIG=$(FMIL_CONFIG)

install-python: docker_environment c-compiler
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_python.sh ${PYTHON_VERSION}

local_environment:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/check_python_version.sh ${PYTHON_VERSION}

cmake:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_cmake.sh

clean_docker: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
clean_docker:
	@docker rmi -f ${DOCKER_ID}

clean:
	rm -rf $(BUILD_DIR)/PYFMI_FOLDERBUILD_$(BITNESS)
	rm -rf $(BUILD_DIR)/PYFMI_WHEELBUILD_$(BITNESS)

