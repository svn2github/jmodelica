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

.PHONY: install fmil_docker_build

install:
	mkdir -p $(BUILD_DIR_FMIL) && \
	cd $(BUILD_DIR_FMIL) && \
	cmake $(GENERATOR) $(EXTRA_CMAKE_FLAGS) -DFMILIB_INSTALL_PREFIX:PATH=$(FMIL_HOME) $(BUILD_EXTERNALS_DIR)/../FMILibrary/FMILibrary/; \
	cd $(BUILD_DIR_FMIL) && make install DESTDIR=

fmil_docker: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
fmil_docker: docker_image
	@echo "Starting docker with id ${DOCKER_ID} in fmil makefile"
	@docker run -v ${PATH_TO_MOUNT}:${JM_HOME_IN_DOCKER} ${DOCKER_ID} sh -c "cd ${JM_HOME_IN_DOCKER}/external/build_externals/build/pyfmi && make fmil_docker_build"
	@docker rmi -f ${DOCKER_ID}

fmil_docker_build: docker_environment c-compiler cmake install
	@echo "Finished building FMIL"

docker_environment:
	${BUILD_EXTERNALS_DIR}/docker/platforms/${PLATFORM}/install_dependencies.sh

c-compiler:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_gcc.sh

# TODO: SHOULD CONFIG PATH BE A VARIABLE OR SHOULD PLATFORM INFO BE IN ALL CONFIGS?
docker_image: dockerfile
	${DOCKER_UTILS_DIR}/build_docker_image.sh ./default_config

dockerfile:
	${DOCKER_UTILS_DIR}/generation/generate_dockerfile.sh

cmake:
	${BUILD_ENVIRONMENT}/platforms/${PLATFORM}/install_cmake.sh

clean: DOCKER_ID = $(shell ${DOCKER_UTILS_DIR}/get_docker_id.sh ./default_config)
clean:
	@docker rmi -f ${DOCKER_ID}

