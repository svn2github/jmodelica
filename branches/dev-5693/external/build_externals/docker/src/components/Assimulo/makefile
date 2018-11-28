
include default_config
include $(USER_CONFIG)

docker_test_wheel docker_test_folder: setup
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID) for testing $(TARGET)"
	@docker run -v $(PATH_TO_MOUNT):$(JM_HOME_IN_DOCKER) ${DOCKER_ID} sh -c \
	    "cd ${DOCKER_CONFIG_HOME} && make $(subst docker_,,$@) JM_HOME=$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"

# starts a docker instance to build either assimulo install folder or wheel
docker_wheel docker_folder: docker_$(TARGET)_dependencies
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT):$(JM_HOME_IN_DOCKER) ${DOCKER_ID} sh -c \
	    "cd ${DOCKER_CONFIG_HOME} && make $(subst docker_,,$@) JM_HOME=$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo $(DISTRO)/$(TARGET)/$(subst docker_,,$@)/** > $(ARTIFACT_FILE)

wheel folder test_wheel test_folder:
	@cd $(BUILD_EXTERNALS)/$(TARGET) && \
	make $@ USER_CONFIG=$(BUILD_DIR)/$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) INSTALL_DIR_FOLDER=$(DOCKER_BUILD_DIR)/$(TARGET)

docker_$(TARGET)_dependencies: docker_base_$(TARGET)
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT):$(JM_HOME_IN_DOCKER) ${DOCKER_ID} sh -c \
	    "cd ${DOCKER_CONFIG_HOME} && make $(subst docker_,,$@) JM_HOME=$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"

docker_base_$(TARGET): setup
	BASE_TYPE="BASE" \
	    INSTALL_BASE_DEPENDENCIES=$(INSTALL_DEPENDENCIES) \
	    CONFIG=$(BUILD_DIR)/default_config \
	    USER_CONFIG=$(BUILD_DIR)/$(USER_CONFIG) \
	    INSTALL_PYTHON=1 \
	    $(DOCKER_UTILS)/generation/generate_dockerfile.sh
	
	cd $(JM_HOME) && \
	    BASE_DIR= \
	    CONFIG=$(BUILD_DIR)/default_config \
	    USER_CONFIG=$(BUILD_DIR)/$(USER_CONFIG) \
	    TAG_NAME=base_$(TARGET)$(DOCKER_NAME_SUFFIX) \
	    DOCKERFILE_DIR=$(DISTRO) \
	    $(DOCKER_UTILS)/build_docker_image.sh 

# builds assimulo dependencies, called upon in a docker environment
assimulo_dependencies: blas lapack sundials

sundials: superlu

lapack blas sundials superlu: 
	cd $(BUILD_THIRDPARTY)/$@ && \
	make install USER_CONFIG=$(DOCKER_CONFIG_HOME)/$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=$(JM_HOME_IN_DOCKER)

setup:
	test -n "${JM_HOME}" # $$JM_HOME
	test -n "${PATH_TO_MOUNT}" # $$PATH_TO_MOUNT
	@mkdir -p $(BUILD_DIR)
	@cp $(CONFIG_HOME)/default_config $(BUILD_DIR)
	@cp $(CONFIG_HOME)/$(USER_CONFIG) $(BUILD_DIR)
	@chmod +x \
	    $(JM_HOME)/Docker/generation/generate_dockerfile.sh \
	    $(JM_HOME)/Docker/build_docker_image.sh \
	    $(JM_HOME)/Docker/get_docker_id.sh \
	    $(JM_HOME)/build_environment/platforms/$(PLATFORM)/install_python$(PYTHON_VERSION).sh \
	    $(JM_HOME)/external/build_externals/docker/platforms/${PLATFORM}/*.sh

clean:
	@ rm -rf $(BUILD_DIR)

# starts a docker process to remove files created by the build system
clean_in_docker:
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT):$(JM_HOME_IN_DOCKER) ${DOCKER_ID} sh -c \
	"cd ${DOCKER_CONFIG_HOME} && make clean JM_HOME=$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"


.PHONY:


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