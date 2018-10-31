#!make
#SHELL := /bin/bash

include default_config
export $(shell sed 's/=.*//' default_config)

include $(USER_CONFIG)
export $(shell sed 's/=.*//' $(USER_CONFIG))

# check for invalid entries (file does not exist yet)
#. check_configuration.sh
.PHONY: assimulo_folder assimulo_wheel

assimulo_folder: LOCAL_BUILD_DIR=$(BUILD_DIR)/ASSIMULO_FOLDERBUILD_$(BITNESS)
assimulo_folder: LOCAL_INSTALL_DIR=$(BUILD_DIR)/ASSIMULO_FOLDERINSTALL_$(BITNESS)
assimulo_folder: PYTHONPATH=$(LOCAL_INSTALL_DIR)/Lib/site-packages
assimulo_folder:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(ASSIMULO_SRC)/../; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/Assimulo; \
	mkdir -p $(LOCAL_INSTALL_DIR)/Lib/site-packages; \
	$(PYTHONHOME)python setup.py install --with_openmp=True --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS) --prefix=$(LOCAL_INSTALL_DIR); \
	cd $(LOCAL_INSTALL_DIR)/Lib/site-packages; \
	mkdir -p $(INSTALL_DIR_FOLDER); \
	find -type d -name assimulo -exec cp -r {} $(INSTALL_DIR_FOLDER) \;	

assimulo_wheel: LOCAL_BUILD_DIR=$(BUILD_DIR)/ASSIMULO_WHEELBUILD_$(BITNESS)
assimulo_wheel:
	mkdir -p ${LOCAL_BUILD_DIR}; \
	cd $(ASSIMULO_SRC)/../; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(LOCAL_BUILD_DIR); \
	cd $(LOCAL_BUILD_DIR)/Assimulo; \
	$(PYTHONHOME)python setup.py bdist_wheel --with_openmp=True --superlu-home=$(SUPERLU_HOME) --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(BLAS_HOME) --lapack-home=$(LAPACK_HOME) $(EXTRA_SETUP_ARGS); \
	find -type f -name Assimulo*.whl -exec cp {} $(INSTALL_DIR_FOLDER) \;	