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

# check for invalid entries (file does not exist yet)
#. check_configuration.sh
.PHONY: assimulo_folder assimulo_wheel

assimulo_folder: LOCAL_BUILD_DIR=$(BUILD_DIR)/ASSIMULO_FOLDERBUILD_$(BITNESS)
assimulo_folder: LOCAL_INSTALL_DIR=$(BUILD_DIR)/ASSIMULO_FOLDERINSTALL_$(BITNESS)
assimulo_folder:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	mkdir -p ${LOCAL_INSTALL_DIR}; \
	cd $(ASSIMULO_SRC)/../; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/Assimulo; \
	$(PYTHONHOME)python setup.py install --with_openmp=True --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS) --prefix=$(LOCAL_INSTALL_DIR); \
	cd $(LOCAL_INSTALL_DIR)/$(PLATFORM_SITE_PACKAGES); \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type d -name assimulo -exec cp -r {} $(INSTALL_DIR_FOLDER) \;	

assimulo_wheel: LOCAL_BUILD_DIR=$(BUILD_DIR)/ASSIMULO_WHEELBUILD_$(BITNESS)
assimulo_wheel:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(ASSIMULO_SRC)/../; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/Assimulo; \
	$(PYTHONHOME)python setup.py bdist_wheel --with_openmp=True --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS); \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type f -name Assimulo*.whl -exec cp {} $(INSTALL_DIR_FOLDER) \;

clean:
	rm -rf $(BUILD_DIR)/ASSIMULO_WHEELBUILD_$(BITNESS)
	rm -rf $(BUILD_DIR)/ASSIMULO_FOLDERBUILD_$(BITNESS)