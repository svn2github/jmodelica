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
#export $(shell sed 's/=.*//' default_config)

include $(USER_CONFIG)
#export $(shell sed 's/=.*//' $(USER_CONFIG))

PYTHON_CONFIG := $(BUILD_EXTERNALS_DIR)/configurations/PyFMI/$(PLATFORM)/python_config
include $(PYTHON_CONFIG)
#export $(shell sed 's/=.*//' $(PYTHON_CONFIG))

# TODO: Add layer squashing

# TODO: Check for invalid entries (file does not exist yet)
#. check_configuration.sh

.EXPORT_ALL_VARIABLES:

.PHONY: fmil dockerfile pyfmi pyfmi_wheel
# TODO: Test building docker configurations (generating different docker_id), and test that we get the correct ID

# TODO: Try OVERRIDE JM_HOME FROM PYFMI_BASE_IMAGE SUCH THAT WE DONT NEED ANY EXTERNAL DOCKER PATHS
#export FMIL_INSTALL_DIR=$(JM_HOME)/$(PLATFORM)_$(DIST_VERSION)/fmil_install

# TODO: Add shell script for docker to commit itself and kill itself for debugging purpose

# TODO: Make one target for pyfmi install folder and create PYTHONPATH & PYTHONHOME through script?

# Builds FMIL, starts new container, installs Python + packages and puts FMIL in image
python_fmil: make_fmil_docker
	cd $(JM_HOME) && \
	${DOCKER_UTILS_DIR}/generation/generate_dockerfile.sh "PYFMI_BASE" && \
	${DOCKER_UTILS_DIR}/build_docker_image.sh default_config $(USER_CONFIG) jmodelica/$(PLATFORM)_python_fmil $(PLATFORM)_$(DIST_VERSION)
	@echo "Finished building pyfmi base image"

python_fmil_dockerhub:
	@echo "Pulling from dockerhub"
	#@docker pull jmodelica/pyfmi_base_$(PLATFORM)

# Note: To build pyfmi_full_image you need to run pyfmi_base_image until its up on dockerhub
pyfmi_full_image: DOCKER_ID = $(shell docker images | grep '$(PLATFORM)_python_fmil' | awk '{print $$3}')
pyfmi_full_image: python_fmil_dockerhub
	@echo "Building full PyFMI full_image with id ${DOCKER_ID}"
	@docker run -v $(PATH_TO_MOUNT):\\$(JM_HOME_IN_DOCKER) ${DOCKER_ID} sh -c \
	"cd ${JM_HOME_IN_DOCKER}/external/build_externals/build/pyfmi && make pyfmi_linux JM_HOME=/$(JM_HOME_IN_DOCKER) INSTALL_DIR=/$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION)/pyfmi_install FMIL_INSTALL=/fmil USER_CONFIG=$(USER_CONFIG)"

# TODO: Move this into pyfmi_base_image
make_fmil_docker:
	[[ -e $(USER_CONFIG) ]] && cp $(USER_CONFIG) $(BUILD_EXTERNALS_DIR)/build/fmil
	cd $(BUILD_EXTERNALS_DIR)/build/fmil && make fmil_docker USER_CONFIG=$(USER_CONFIG)


    
# TODO: Fix one unified target for windows/linux because PYTHONPATH is different
#       and cant override PYTHONHOME in CentOS, then it wont work
pyfmi_linux: PYFMI_BUILD_DIR=$(BUILD_DIR)/PYFMI_FOLDERBUILD_$(BITNESS)
pyfmi_linux: PYFMI_INSTALL_DIR=$(BUILD_DIR)/PYFMI_FOLDERINSTALL_$(BITNESS)
pyfmi_linux:
	mkdir -p ${PYFMI_BUILD_DIR}; \
	cd $(PYFMI_SRC)/../; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(PYFMI_BUILD_DIR); \
	cd $(PYFMI_BUILD_DIR)/PyFMI; \
	mkdir -p $(PYTHONPATH); \
	$(PYTHON_BIN) setup.py install --fmil-home=$(FMIL_INSTALL) $(EXTRA_SETUP_ARGS) --prefix=$(PYFMI_INSTALL_DIR); \
	cd $(PYTHONPATH); \
	mkdir -p $(INSTALL_DIR); \
	find -type d -name pyfmi -exec cp -r {} $(INSTALL_DIR) \;

pyfmi_wheel: PYFMI_BUILD_DIR=$(BUILD_DIR)/PYFMI_WHEELBUILD_$(BITNESS)
pyfmi_wheel:
	mkdir -p ${PYFMI_BUILD_DIR}; \
	cd $(PYFMI_SRC)/../; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(PYFMI_BUILD_DIR); \
	cd $(PYFMI_BUILD_DIR)/PyFMI; \
	$(PYTHONHOME)python setup.py bdist_wheel --fmil-home=$(FMIL_INSTALL) $(EXTRA_SETUP_ARGS); \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type f -name PyFMI*.whl -exec cp {} $(INSTALL_DIR_FOLDER) \;

pyfmi_folder: LOCAL_BUILD_DIR=$(BUILD_DIR)/PYFMI_FOLDERBUILD_$(BITNESS)
pyfmi_folder: LOCAL_INSTALL_DIR=$(BUILD_DIR)/PYFMI_FOLDERINSTALL_$(BITNESS)
pyfmi_folder:
	mkdir -p ${PYFMI_BUILD_DIR}; \
	cd $(PYFMI_SRC)/../; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/PyFMI; \
	$(PYTHONHOME)python setup.py install --fmil-home=$(FMIL_INSTALL) $(EXTRA_SETUP_ARGS) --prefix=$(LOCAL_INSTALL_DIR); \
	cd $(LOCAL_INSTALL_DIR)/Lib/site-packages; \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type d -name pyfmi -exec cp -r {} $(INSTALL_DIR_FOLDER) \;

fmil: 
	cd $(BUILD_EXTERNALS_DIR)/build/fmil; \
	make install BUILD_EXTERNALS_DIR=$(BUILD_EXTERNALS_DIR) FMIL_INSTALL=$(FMIL_INSTALL) BUILD_DIR=$(BUILD_DIR) USER_CONFIG=$(FMIL_CONFIG)

clean_docker: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
clean_docker:
	@docker rmi -f ${DOCKER_ID}

clean:
	rm -rf $(BUILD_DIR)/PYFMI_FOLDERBUILD_$(BITNESS)
	rm -rf $(BUILD_DIR)/PYFMI_WHEELBUILD_$(BITNESS)

