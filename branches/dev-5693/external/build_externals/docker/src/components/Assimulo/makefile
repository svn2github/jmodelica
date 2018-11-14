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

docker_assimulo_folder docker_assimulo_wheel: assimulo_base_image
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG) BASE))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	    "cd ${DOCKER_CONFIG_HOME} && make $(subst docker_,,$@) JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"

assimulo_folder assimulo_wheel:
	cp $(USER_CONFIG) $(BUILD_EXTERNALS)/assimulo/
	cd $(BUILD_EXTERNALS)/assimulo && \
	make $@ USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=//$(JM_HOME_IN_DOCKER) \
	    INSTALL_DIR_FOLDER=//tmp/jm_home/$(OS)/$@

assimulo_base_image: docker_assimulo_dependencies
	cp $(CONFIG_HOME)/default_config $(BUILD_DIR)
	cp $(CONFIG_HOME)/$(USER_CONFIG) $(BUILD_DIR)
	cd $(JM_HOME) && \
	${DOCKER_UTILS}/generation/generate_dockerfile.sh "ASSIMULO_BASE" $(INSTALL_DEPENDENCIES) $(OS)/default_config $(OS)/$(USER_CONFIG) && \
	${DOCKER_UTILS}/build_docker_image.sh $(OS)/default_config $(OS)/$(USER_CONFIG) jmodelica/$(PLATFORM)_assimulo_base $(OS) BASE

base_dependency: modify_permissions
	@mkdir -p $(BUILD_DIR)
	$(DOCKER_UTILS)/generation/generate_dockerfile.sh "BASE" $(INSTALL_DEPENDENCIES) default_config $(USER_CONFIG) && \
	$(DOCKER_UTILS)/build_docker_image.sh default_config $(USER_CONFIG) jmodelica/$(PLATFORM)_$(BUILD_TARGET)_dep $(OS)

docker_assimulo_dependencies: base_dependency
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "dafuq"
	@echo "Starting: docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	    "cd ${DOCKER_CONFIG_HOME} && make $(subst docker_,,$@) JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"
	@echo finished1

clean:
	@ rm -rf $(BUILD_DIR)

clean_in_docker:
	@$(eval DOCKER_ID=$(shell ${DOCKER_UTILS}/get_docker_id.sh default_config $(USER_CONFIG)))
	@echo "Starting docker container with ID=$(DOCKER_ID)"
	@docker run -v $(PATH_TO_MOUNT)://tmp/jm_home ${DOCKER_ID} sh -c \
	"cd ${DOCKER_CONFIG_HOME} && make clean JM_HOME=/$(JM_HOME_IN_DOCKER) USER_CONFIG=$(USER_CONFIG)"

# Make build scripts executable for CI
modify_permissions:
	@chmod +x $(JM_HOME)/Docker/generation/generate_dockerfile.sh
	@chmod +x $(JM_HOME)/Docker/build_docker_image.sh
	@chmod +x $(JM_HOME)/Docker/get_docker_id.sh
	@chmod +x $(JM_HOME)/build_environment/platforms/$(PLATFORM)/install_python$(PYTHON_VERSION).sh

# Used by CI for archiving artifacts
artifact_list:
	@echo $(OS)/assimulo_wheel/*.whl, $(OS)/assimulo_folder/assimulo > $@ 

assimulo_dependencies: sundials blas lapack

sundials: superlu
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY)/sundials/ && cd $(BUILD_THIRDPARTY)/sundials && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=//$(JM_HOME_IN_DOCKER)

superlu: 
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY)/superlu/ && cd $(BUILD_THIRDPARTY)/superlu && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=//$(JM_HOME_IN_DOCKER)

blas:
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY)/blas/ && cd $(BUILD_THIRDPARTY)/blas && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=//$(JM_HOME_IN_DOCKER)

lapack:
	cp $(USER_CONFIG) $(BUILD_THIRDPARTY)/lapack/ && cd $(BUILD_THIRDPARTY)/lapack && \
	make install USER_CONFIG=$(USER_CONFIG) BUILD_DIR=$(DOCKER_BUILD_DIR) JM_HOME=//$(JM_HOME_IN_DOCKER)

.PHONY:
