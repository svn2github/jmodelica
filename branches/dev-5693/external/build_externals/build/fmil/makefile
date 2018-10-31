#!make
#SHELL := /bin/bash

include default_config
export $(shell sed 's/=.*//' default_config)

include $(USER_CONFIG)
export $(shell sed 's/=.*//' $(USER_CONFIG))

#TODO add layer squashing

# check for invalid entries (file does not exist yet)
#. check_configuration.sh
.PHONY: install 

install:
	mkdir -p $(BUILD_DIR_FMIL) && \
	cd $(BUILD_DIR_FMIL) && \
	cmake $(GENERATOR) $(EXTRA_CMAKE_FLAGS) -DFMILIB_INSTALL_PREFIX:PATH=$(FMIL_HOME) $(BUILD_EXTERNALS_DIR)/../FMILibrary/FMILibrary/; \
	cd $(BUILD_DIR_FMIL) && make install DESTDIR=
