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


include default_config

include $(USER_CONFIG)


# TODO: python_config should not be located in .../PyFMI/...
PYTHON_CONFIG := $(BUILD_EXTERNALS_DIR)/configurations/PyFMI/$(PLATFORM)/python_config
include $(PYTHON_CONFIG)

# TODO: Remove this, it affects build_docker_image.sh
#.EXPORT_ALL_VARIABLES:

assimulo_wheel:
	@echo "Building $@"
	cp $(USER_CONFIG) $(BUILD_EXTERNALS_DIR)/build/assimulo/ && cd $(BUILD_EXTERNALS_DIR)/build/assimulo && \
	pip3 install setuptools && make assimulo_wheel USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER) \
	INSTALL_DIR_FOLDER=//tmp/jm_home/$(PLATFORM)_$(DIST_VERSION)/assimulo_wheel
	@echo "Finished building $@"

assimulo_folder:
	@echo "Building $@"
	cp $(USER_CONFIG) $(BUILD_EXTERNALS_DIR)/build/assimulo/ && \
	cd $(BUILD_EXTERNALS_DIR)/build/assimulo && \
	make assimulo_folder USER_CONFIG=$(USER_CONFIG) BUILD_DIR=//tmp/jm_home/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER) \
	INSTALL_DIR_FOLDER=//tmp/jm_home/$(PLATFORM)_$(DIST_VERSION)/assimulo_folder
	@echo "Finished building $@"

docker_assimulo_folder: build_assimulo_base_image
	@echo "Building $@"
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh default_config $(USER_CONFIG) BASE))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	"cd ${BUILD_HOME_DIR_DOCKER} && make assimulo_folder JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo "Finished building $@"

docker_assimulo_wheel: build_assimulo_base_image
	@echo "Building $@"
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh default_config $(USER_CONFIG) BASE))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	"cd ${BUILD_HOME_DIR_DOCKER} && make assimulo_wheel JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo "Finished building $@"

build_assimulo_base_image: docker_assimulo_dependencies
	@echo "Building $@"
	cp $(BUILD_HOME_DIR_LOCAL)/default_config $(JM_HOME)/$(PLATFORM)_$(DIST_VERSION) && \
	cp $(BUILD_HOME_DIR_LOCAL)/$(USER_CONFIG) $(JM_HOME)/$(PLATFORM)_$(DIST_VERSION) && \
	cd $(JM_HOME) && \
	${DOCKER_UTILS_DIR}/generation/generate_dockerfile.sh "ASSIMULO_BASE" $(DEPENDENCY_BASE_COMMAND) $(PLATFORM)_$(DIST_VERSION)/default_config $(PLATFORM)_$(DIST_VERSION)/$(USER_CONFIG) && \
	${DOCKER_UTILS_DIR}/build_docker_image.sh $(PLATFORM)_$(DIST_VERSION)/default_config $(PLATFORM)_$(DIST_VERSION)/$(USER_CONFIG) jmodelica/$(PLATFORM)_assimulo_base $(PLATFORM)_$(DIST_VERSION) BASE
	@echo "Finished building $@"

assimulo_dependencies: sundials blas lapack

sundials: superlu
	@echo "Building $@"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/sundials/ && cd $(BUILD_THIRDPARTY_DIR)/sundials && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building $@"

superlu: 
	@echo "Building $@"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/superlu/ && cd $(BUILD_THIRDPARTY_DIR)/superlu && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building $@"

blas:
	@echo "Building $@"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/blas/ && cd $(BUILD_THIRDPARTY_DIR)/blas && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building blas"

lapack:
	@echo "Building $@"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/lapack/ && cd $(BUILD_THIRDPARTY_DIR)/lapack && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building $@"

docker_base: modify_permissions
	@echo "Building $@"
	@echo "Creating directory $(JM_HOME)/$(PLATFORM)_$(DIST_VERSION)"
	@mkdir -p $(JM_HOME)/$(PLATFORM)_$(DIST_VERSION)
	@echo "Creating dockerfile and building image"
	$(DOCKER_UTILS_DIR)/generation/generate_dockerfile.sh "BASE" $(DEPENDENCY_BASE_COMMAND) default_config $(USER_CONFIG) && \
	$(DOCKER_UTILS_DIR)/build_docker_image.sh default_config $(USER_CONFIG) jmodelica/$(PLATFORM)_$(BUILD_TARGET)_dep $(PLATFORM)_$(DIST_VERSION)
	@echo "Finished $@"

modify_permissions:
	@echo "Building $@"
	@chmod +x $(JM_HOME)/Docker/generation/generate_dockerfile.sh
	@chmod +x $(JM_HOME)/Docker/build_docker_image.sh
	@chmod +x $(JM_HOME)/Docker/get_docker_id.sh
	@chmod +x $(JM_HOME)/build_environment/platforms/$(PLATFORM)/install_python$(PYTHON_VERSION).sh

docker_assimulo_dependencies: docker_base
	@echo "Building $@"
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	"cd ${BUILD_HOME_DIR_DOCKER} && ls && pwd && make assimulo_dependencies JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo "Finished building $@"

clean_in_docker:
	@echo "Building $@"
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	"cd ${BUILD_HOME_DIR_DOCKER} && make clean JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo "Finished building $@"

clean:
	@echo "Building $@"
	@ rm -rf $(JM_HOME)/$(PLATFORM)_$(DIST_VERSION)
	@echo "Finished building $@"


.PHONY:
