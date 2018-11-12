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
.EXPORT_ALL_VARIABLES:

assimulo: assimulo_dependencies
	@echo "Building Assimulo"
	cp $(USER_CONFIG) $(BUILD_EXTERNALS_DIR)/build/assimulo/ && cd $(BUILD_EXTERNALS_DIR)/build/assimulo && \
	make assimulo_folder USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building sundials"

assimulo_dependencies:
	@echo "Check if base exists else use docker pull or rebuild"

docker_assimulo_dependencies: clean sundials blas lapack

sundials: superlu
	@echo "Building sundials"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/sundials/ && cd $(BUILD_THIRDPARTY_DIR)/sundials && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building sundials"

superlu: 
	@echo "Building SuperLU"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/superlu/ && cd $(BUILD_THIRDPARTY_DIR)/superlu && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)

blas:
	@echo "Building blas"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/blas/ && cd $(BUILD_THIRDPARTY_DIR)/blas && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building blas"

lapack:
	@echo "Building lapack"
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY_DIR)/lapack/ && cd $(BUILD_THIRDPARTY_DIR)/lapack && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(JM_HOME_IN_DOCKER)/$(PLATFORM)_$(DIST_VERSION) JM_HOME=//$(JM_HOME_IN_DOCKER)
	@echo "Finished building lapack"
docker_environment:
	@echo "Building environment (cd and make)"

docker_base:
	@echo "Starting docker process"
	$(DOCKER_UTILS_DIR)/generation/generate_dockerfile.sh "BASE" $(DEPENDENCY_BASE_COMMAND) && \
	$(DOCKER_UTILS_DIR)/build_docker_image.sh default_config $(USER_CONFIG) jmodelica/$(PLATFORM)_$(BUILD_TARGET)_base $(PLATFORM)_$(DIST_VERSION)
	@echo "Finished building $(BUILD_TARGET) base image"

docker_assimulo_base: docker_base
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT):/tmp/jm_home ${DOCKER_ID} sh -c \
	"ls -la && ls -la /tmp && cd ${BUILD_HOME_DIR} && make docker_assimulo_dependencies JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo "Start new docker image with a Dockerfile that COPIES all the artifacts into a clean image"
	@echo "Finished building assimulo base image"

clean_docker: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
clean_docker:
	@docker rmi -f ${DOCKER_ID}

clean:
	@ rm -rf $(JM_HOME)/$(PLATFORM)_$(DIST_VERSION)


.PHONY:
