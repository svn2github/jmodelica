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

test:
	nosetests tests/*.pyc tests/solvers/*.pyc

test_wheel:
	@echo -e "\e[33m" "Got WHEEL_INSTALL_DIR=$(WHEEL_INSTALL_DIR)" "\e[0m"
	@pip install $(INSTALL_DIR_FOLDER)/$(TARGET)/$(subst test_,,$@)/*.whl
	nosetests $(WHEEL_INSTALL_DIR)/tests/*.pyc $(WHEEL_INSTALL_DIR)/tests/solvers/*.pyc


test_folder:
	@echo  -e "\e[33m" "Got ASSIMULO_FOLDER_INSTALL_DIR=$(ASSIMULO_FOLDER_INSTALL_DIR)" "\e[0m"
	nosetests $(ASSIMULO_FOLDER_INSTALL_DIR)/tests/*.pyc $(ASSIMULO_FOLDER_INSTALL_DIR)/tests/solvers/*.pyc

folder: LOCAL_BUILD_DIR=$(BUILD_DIR)/ASSIMULO_FOLDERBUILD_$(BITNESS)
folder: LOCAL_INSTALL_DIR=$(BUILD_DIR)/ASSIMULO_FOLDERINSTALL_$(BITNESS)
folder:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	mkdir -p ${LOCAL_INSTALL_DIR}; \
	cd $(ASSIMULO_SRC)/../; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/Assimulo; \
	$(PYTHONHOME)python setup.py install --with_openmp=True --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS) --prefix=$(LOCAL_INSTALL_DIR); \
	cd $(LOCAL_INSTALL_DIR)/$(PLATFORM_SITE_PACKAGES); \
	mkdir -p $(INSTALL_DIR_FOLDER)/folder; \
	find -type d -name assimulo -exec cp -r {} $(INSTALL_DIR_FOLDER)/$@ \;	

wheel: LOCAL_BUILD_DIR=$(BUILD_DIR)/ASSIMULO_WHEELBUILD_$(BITNESS)
wheel:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(ASSIMULO_SRC)/../; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/Assimulo; \
	$(PYTHONHOME)python setup.py bdist_wheel --with_openmp=True --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS); \
	mkdir -p $(INSTALL_DIR_FOLDER)/$@; \
	find -type f -name Assimulo*.whl -exec cp {} $(INSTALL_DIR_FOLDER)/$@/Assimulo-1.0.0-cp27-cp27mu-linux_x86_64.whl \;

clean:
	rm -rf $(BUILD_DIR)/ASSIMULO_WHEELBUILD_$(BITNESS)
	rm -rf $(BUILD_DIR)/ASSIMULO_FOLDERBUILD_$(BITNESS)