# 
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.


AUTOMAKE_OPTIONS = foreign
ACLOCAL_AMFLAGS = -I m4

SUBDIRS = ThirdParty/SuperLU ThirdParty/Sundials ThirdParty/Minpack ThirdParty/Blas ThirdParty/Lapack external/FMILibrary RuntimeLibrary Python

assimulo_install_dir=$(abs_builddir)/Assimulo_install
pymodelica_install_dir=$(abs_builddir)/pymodelica_install
pyfmi_install_dir=$(abs_builddir)/PyFMI_install
pyjmi_install_dir=$(abs_builddir)/PyJMI_install

assimulo_build_dir=$(abs_builddir)/Assimulo_build
pymodelica_build_dir=$(abs_builddir)/pymodelica_build
pyfmi_build_dir=$(abs_builddir)/PyFMI_build
pyjmi_build_dir=$(abs_builddir)/PyJMI_build

bindistdir=JModelica.org-$(VERSION)-bin

casadi:
	cd $(abs_builddir)/ThirdParty/CasADi; \
	make -f Makefile  "SWIGCHECK_BUILD_DIR=$(SWIGCHECK_BUILD_DIR)" "CASADI_BUILD_DIR=$(CASADI_BUILD_DIR)" "IPOPT_HOME=$(IPOPT_HOME)"

install_casadi: casadi
	cd $(abs_builddir)/ThirdParty/CasADi; \
	make -f Makefile install "SWIGCHECK_BUILD_DIR=$(SWIGCHECK_BUILD_DIR)" "CASADI_BUILD_DIR=$(CASADI_BUILD_DIR)" "IPOPT_HOME=$(IPOPT_HOME)"
	mkdir -p $(DESTDIR)$(prefix)/Python/
	cp -r $(abs_builddir)/casadi_install/casadi $(DESTDIR)$(prefix)/Python/
	## temp fix
	cp $(abs_builddir)/casadi_build/swig/casadi_core.py $(DESTDIR)$(prefix)/Python/casadi

## Install for CasADiInterface, Variables and targets. 
## MC_interface installs the system with Python. 
## If C++ compilation/tests are wanted there is the target MC_interface_cplusplus

MC_INTERFACE=$(abs_top_srcdir)/ModelicaCasADiInterface

CASADI_HOME=$(abs_top_srcdir)/ThirdParty/CasADi/CasADi
MC_SRC=$(JAVA_CASADI_BASE_DIR)/ModelicaCompilerCasADi
OC_SRC=$(JAVA_CASADI_BASE_DIR)/OptimicaCompilerCasADi
MC_SRC_SWIG=$(abs_top_srcdir)/Compiler/ModelicaCompilerCasADi/src/swig

MC_CASADI_BUILD=$(abs_builddir)/ModelicaCompilerCasADi
OC_CASADI_BUILD=$(abs_builddir)/OptimicaCompilerCasADi

# The modelica casadi interface is built into a build folder
MC_BUILD=$(abs_builddir)/ModelicaCasADiInterfaceBuild
# Jars from the modified modelica and optimica compilers are put into the JModelica folder
MC_COMPILERS_DIR=$(MC_BUILD)/JModelica.org
MC_LIB=$(DESTDIR)$(prefix)/lib/casadi_interface

CASADI_BUILD_DIR=$(abs_builddir)/casadi_build
SWIGCHECK_BUILD_DIR=$(abs_builddir)/swig_check


casadi_interface: install_casadi_interface
build_casadi_interface: casadi modelicacasadi_wrapper
install_casadi_interface: install_casadi $(MC_LIB) $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/__init__.py $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper/__init__.py $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/modelica_casadi_transfer_wrapper.py
	if [ "$(INSTALL_EXTRA_CASADI)" ]; then exec "$(INSTALL_EXTRA_CASADI)" "$(abs_top_srcdir)" "$(DESTDIR)$(prefix)"; fi

ifcasadi: casadi
	mkdir -p $(MC_BUILD)/ifcasadi; \
	cd $(MC_BUILD)/ifcasadi; \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake $(MC_SRC_SWIG) -G "MSYS Makefiles" -DCMAKE_CXX_COMPILER_ARG1="-m32" -DCMAKE_CXX_FLAGS="-m32" \
	    -DIFCASADI_OUTDIR="$(MC_CASADI_BUILD)" -DCASADI_HOME="$(CASADI_HOME)" -DCASADI_BUILD_DIR="$(CASADI_BUILD_DIR)";; \
	*) \
	cmake $(MC_SRC_SWIG) \
	    -DIFCASADI_OUTDIR="$(MC_CASADI_BUILD)" -DCASADI_HOME="$(CASADI_HOME)" -DCASADI_BUILD_DIR="$(CASADI_BUILD_DIR)";; \
	esac 
	cd $(MC_BUILD)/ifcasadi;  make

$(MC_LIB): $(MC_CASADI_BUILD)/bin/ModelicaCompiler.jar $(OC_CASADI_BUILD)/bin/OptimicaCompiler.jar $(MC_CASADI_BUILD)/bin/util.jar ifcasadi
	rm -rf $(MC_LIB)
	mkdir -p $(MC_LIB)
	cp $(MC_CASADI_BUILD)/bin/ModelicaCompiler.jar $(MC_LIB)
	cp $(OC_CASADI_BUILD)/bin/OptimicaCompiler.jar $(MC_LIB)
	cp $(MC_CASADI_BUILD)/bin/util.jar $(MC_LIB)
	case $(build) in \
	*-cygwin*) \
	cp $(MC_BUILD)/ifcasadi/ifcasadi.dll $(MC_LIB) ;; \
	*-mingw*) \
	cp $(MC_BUILD)/ifcasadi/ifcasadi.dll $(MC_LIB) ;; \
	*) \
	cp $(MC_BUILD)/ifcasadi/libifcasadi.so $(MC_LIB) ;; \
	esac 

mc_modelica: ifcasadi
	cd $(MC_CASADI_BUILD); $(ANT_OPTS) $(ANT) -f "$(JAVA_MC_CASADI_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"

mc_optimica: ifcasadi
	mkdir -p $(OC_CASADI_BUILD)/src/java-generated
	cp -pr $(MC_CASADI_BUILD)/src/java-generated/ifcasadi $(OC_CASADI_BUILD)/src/java-generated
	cd $(OC_CASADI_BUILD); $(ANT_OPTS) $(ANT) -f "$(JAVA_OC_CASADI_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"

$(MC_CASADI_BUILD)/bin/ModelicaCompiler.jar: mc_modelica
$(MC_CASADI_BUILD)/bin/util.jar:             mc_modelica
$(MC_CASADI_BUILD)/bin/separateProcess.jar:  mc_modelica

$(OC_CASADI_BUILD)/bin/OptimicaCompiler.jar: mc_optimica
$(OC_CASADI_BUILD)/bin/util.jar:             mc_optimica
$(OC_CASADI_BUILD)/bin/separateProcess.jar:  mc_optimica

$(MC_BUILD)/modelicacasadi_wrapper/swig/modelicacasadi_wrapper.py: modelicacasadi_wrapper


modelicacasadi_wrapper: $(MC_CASADI_BUILD)/bin/ModelicaCompiler.jar $(OC_CASADI_BUILD)/bin/OptimicaCompiler.jar $(MC_CASADI_BUILD)/bin/util.jar ifcasadi # $(MC_LIB)
	mkdir -p $(MC_BUILD)/modelicacasadi_wrapper; \
	cd $(MC_BUILD)/modelicacasadi_wrapper; \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake $(MC_INTERFACE) -G "MSYS Makefiles" -DCMAKE_CXX_COMPILER_ARG1="-m32" -DCMAKE_CXX_FLAGS="-m32" \
	    -DMC_BUILD="$(MC_BUILD)" -DIPOPT_HOME="$(IPOPT_HOME)" -DCASADI_BUILD_DIR="$(CASADI_BUILD_DIR)" \
	    -DIFCASADI_JAR_BASE="$(JAVA_CASADI_BUILD_DIR)" -DCASADI_HOME="$(CASADI_HOME)" \
	    "$(CMAKE_PYTHON_LIB)" "$(CMAKE_PYTHON_INCLUDE)" ;; \
	*) \
	cmake $(MC_INTERFACE) \
	    -DMC_BUILD="$(MC_BUILD)" -DIPOPT_HOME="$(IPOPT_HOME)" -DCASADI_BUILD_DIR="$(CASADI_BUILD_DIR)" \
	    -DIFCASADI_JAR_BASE="$(JAVA_CASADI_BUILD_DIR)" -DCASADI_HOME="$(CASADI_HOME)" \
	    "$(CMAKE_PYTHON_LIB)" "$(CMAKE_PYTHON_INCLUDE)" ;; \
	esac 
	cd $(MC_BUILD)/modelicacasadi_wrapper;  make modelicacasadi_wrapper


 $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/__init__.py: install_modelicacasadi_transfer
 $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/modelica_casadi_transfer_wrapper.py: install_modelicacasadi_transfer
 
 $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper/__init__.py: install_modelicacasadi_wrapper
 
 install_modelicacasadi_wrapper: $(MC_BUILD)/modelicacasadi_wrapper/swig/modelicacasadi_wrapper.py
	mkdir -p $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper
	cp $(MC_BUILD)/modelicacasadi_wrapper/swig/*modelicacasadi_wrapper* $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper 
	rm -f $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper/__init__.py
	touch $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper/__init__.py
	echo "from modelicacasadi_wrapper import *" >> $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper/__init__.py

 install_modelicacasadi_transfer: $(MC_INTERFACE)/python/modelica_casadi_transfer_wrapper.py 
	mkdir -p $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer
	rm -f $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/__init__.py
	touch $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/__init__.py
	echo "from modelica_casadi_transfer_wrapper import *" >> $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/__init__.py
	cp $(MC_INTERFACE)/python/modelica_casadi_transfer_wrapper.py $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer

if NUMPY_NO_MSVCR
NUMPY_NO_MSVCR_ARG=--no-msvcr="true"
else
NUMPY_NO_MSVCR_ARG=
endif

build-python-packages:

if WITH_SUNDIALS
if WITH_OPENMP
	mkdir -p $(assimulo_build_dir); \
	cd $(abs_top_srcdir)/external; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(assimulo_build_dir); \
	cd $(assimulo_build_dir)/Assimulo; \
	case $(build) in \
	*-cygwin*) \
	python setup.py install --with_openmp=True --superlu-home=$(abs_builddir)/superlu_build/ --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*-mingw*) \
	python setup.py install --with_openmp=True --superlu-home=$(abs_builddir)/superlu_build/ --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" $(NUMPY_NO_MSVCR_ARG) --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*) \
	python setup.py install --with_openmp=True --superlu-home=$(abs_builddir)/superlu_build/ --sundials-home=$(SUNDIALS_HOME) --sundials-with-superlu=True --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --prefix=$(assimulo_install_dir) ;; \
	esac
endif
endif
if WITH_SUNDIALS
if !WITH_OPENMP
	mkdir -p $(assimulo_build_dir); \
	cd $(abs_top_srcdir)/external; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(assimulo_build_dir); \
	cd $(assimulo_build_dir)/Assimulo; \
	case $(build) in \
	*-cygwin*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*-mingw*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" $(NUMPY_NO_MSVCR_ARG) --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --prefix=$(assimulo_install_dir) ;; \
	esac
endif
endif
	cd $(abs_top_srcdir)/Python/src; \
	python setup_pymodelica.py install --prefix=$(pymodelica_install_dir); \
	rm -rf build

	mkdir -p $(pyfmi_build_dir); \
	cd $(abs_top_srcdir)/external; \
	find PyFMI -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(pyfmi_build_dir); \
	cd $(pyfmi_build_dir)/PyFMI; \
	case $(build) in \
	*-cygwin*) \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --force-32bit="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(pyfmi_install_dir) ;; \
	*-mingw*) \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --force-32bit="true" $(NUMPY_NO_MSVCR_ARG) --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(pyfmi_install_dir) ;; \
	*) \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --prefix=$(pyfmi_install_dir) ;; \
	esac
	rm -rf build

	cd $(abs_top_srcdir)/Python/src; \
	python setup_pyjmi.py install --prefix=$(pyjmi_install_dir); \
	rm -rf build

install-python-packages: build-python-packages
	mkdir -p $(DESTDIR)$(prefix)/Python
	cp $(abs_top_srcdir)/Python/src/startup.py $(DESTDIR)$(prefix)/
	cp Python/src/required_defaults.py $(DESTDIR)$(prefix)/Python/
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/Python/LICENSE $(DESTDIR)$(prefix)/Python
if WITH_SUNDIALS
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(assimulo_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(assimulo_install_dir)/$${pkgdir}/site-packages/; \
	find assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
endif 
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(pymodelica_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(pymodelica_install_dir)/$${pkgdir}/site-packages/; \
	find pymodelica -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(pyjmi_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(pyjmi_install_dir)/$${pkgdir}/site-packages/; \
	find pyjmi -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
	for pkgdir in lib/python2.5 lib/python2.6 lib/python2.7 lib64/python2.5 lib64/python2.6 lib64/python2.7 Lib; do \
	if [ -e $(pyfmi_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(pyfmi_install_dir)/$${pkgdir}/site-packages/; \
	find pyfmi -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done
	cd $(abs_top_srcdir)/Python/src/tests_jmodelica/; \
	mkdir -p $(DESTDIR)$(prefix)/Python/tests_jmodelica; \
	find . -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python/tests_jmodelica
	rm -rf $(DESTDIR)$(prefix)/Python/tests_jmodelica/files/Modelica/Resources/src
	rm -f $(DESTDIR)$(prefix)/Python/tests_jmodelica/files/Modelica/Resources/CMakeLists.txt
	rm -f $(DESTDIR)$(prefix)/Python/tests_jmodelica/files/Modelica/Resources/Makefile.am
	rm -f $(DESTDIR)$(prefix)/Python/tests_jmodelica/files/Modelica/Resources/Makefile.in
	mkdir -p $(DESTDIR)$(prefix)/bin
	[ -e $(DESTDIR)$(prefix)/bin/jm_python.sh ] && echo "File exists, don't copy jm_python.sh" || cp Python/jm_python.sh $(DESTDIR)$(prefix)/bin/jm_python.sh
	[ -e $(DESTDIR)$(prefix)/bin/jm_ipython.sh  ] && echo "File exists, don't jm_ipython.sh" || cp Python/jm_ipython.sh $(DESTDIR)$(prefix)/bin/jm_ipython.sh
	chmod ugo+x $(DESTDIR)$(prefix)/bin/jm_*.sh

# Hooks for extra build or install actions. Must be empty or the path of a shell script to execute. 
# Both scripts will get the source directory as the first argument and the install directory as the second.
BUILD_EXTRA=
INSTALL_EXTRA=
INSTALL_EXTRA_CASADI=

# Paths for Java build
JAVA_BUILD_DIR=$(abs_builddir)/java
COMPILER_DIR=$(abs_top_srcdir)/Compiler
JAVA_MC_ANT_FILE=$(COMPILER_DIR)/ModelicaCompiler/build.xml
JAVA_OC_ANT_FILE=$(COMPILER_DIR)/OptimicaCompiler/build.xml
JAVA_CASADI_BASE_DIR=$(COMPILER_DIR)
JAVA_CASADI_BUILD_DIR=$(abs_builddir)
JAVA_MC_CASADI_ANT_FILE=$(COMPILER_DIR)/ModelicaCompilerCasADi/build.xml
JAVA_OC_CASADI_ANT_FILE=$(COMPILER_DIR)/OptimicaCompilerCasADi/build.xml
JAVA_EXEC_CP=$(JAVA_BUILD_DIR)/bin/ModelicaCompiler.jar:$(JAVA_BUILD_DIR)/bin/util.jar:$(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver-rt.jar

all-local: build-python-packages build-compiler
	$(abs_top_srcdir)/get_version.sh $(abs_top_srcdir) https://svn.jmodelica.org > $(abs_builddir)/version.txt
	if [ "$(BUILD_EXTRA)" ]; then exec "$(BUILD_EXTRA)" "$(abs_top_srcdir)" "$(DESTDIR)$(prefix)"; fi

build-compiler:
if HAVE_ANT
	mkdir -p $(JAVA_BUILD_DIR)
	cd $(JAVA_BUILD_DIR); \
	$(ANT_OPTS) $(ANT) -f "$(JAVA_MC_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"
	cd $(JAVA_BUILD_DIR); \
	$(ANT_OPTS) $(ANT) -f "$(JAVA_OC_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"
	java -cp "$(JAVA_EXEC_CP)" org.jmodelica.modelica.compiler.ModelicaCompiler\$$OptionExporter -x "$(abs_builddir)/DefaultOptions.xml"
endif

install-exec-local: install-python-packages
if HAVE_ANT
	cp $(JAVA_BUILD_DIR)/bin/ModelicaCompiler.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/util.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/OptimicaCompiler.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/separateProcess.jar $(DESTDIR)$(prefix)/lib/
endif
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/LICENSE $(DESTDIR)$(prefix)/ 
	cp $(abs_top_srcdir)/RuntimeLibrary/LICENSE_GPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/RuntimeLibrary/LICENSE_CPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/RuntimeLibrary/LICENSE_GPL $(DESTDIR)$(prefix)/include/
	cp $(abs_top_srcdir)/RuntimeLibrary/LICENSE_CPL $(DESTDIR)$(prefix)/include/
	mkdir -p $(DESTDIR)$(prefix)/Makefiles
	cp $(abs_top_srcdir)/RuntimeLibrary/LICENSE_GPL $(DESTDIR)$(prefix)/Makefiles/LICENSE
	case $(build) in \
	*-cygwin*) \
	cp $(abs_top_srcdir)/RuntimeLibrary/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/Makefile ;; \
	*-mingw*) \
	cp $(abs_top_srcdir)/RuntimeLibrary/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
	*-apple*) \
	cp $(abs_top_srcdir)/RuntimeLibrary/Makefiles/Makefile.macosx $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
	*) \
	cp $(abs_top_srcdir)/RuntimeLibrary/Makefiles/Makefile.linux $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
	esac

if COPY_PTHREADS_LIB
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/pthreads/lib
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/pthreads/include
	cp $(abs_top_srcdir)/ThirdParty/pthreads/lib/win32/libpthreadGC2-2-9-1.a $(DESTDIR)$(prefix)/ThirdParty/pthreads/lib
	cp $(abs_top_srcdir)/ThirdParty/pthreads/include/*.h $(DESTDIR)$(prefix)/ThirdParty/pthreads/include
endif

	cp $(abs_builddir)/DefaultOptions.xml $(DESTDIR)$(prefix)/DefaultOptions.xml
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/LICENSE $(DESTDIR)$(prefix)/ThirdParty/Beaver/
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver-rt.jar $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib/ 
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Sundials
	cp -r $(SUNDIALS_HOME)/* $(DESTDIR)$(prefix)/ThirdParty/Sundials
	cp $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.7.0/LICENSE $(DESTDIR)$(prefix)/ThirdParty/Sundials
if JM_WIN64
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Sundials/lib64
	cp -r $(SUNDIALS_HOME)64/lib/* $(DESTDIR)$(prefix)/ThirdParty/Sundials/lib64
endif
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Minpack	
	cp -r $(MINPACK_HOME)/* $(DESTDIR)$(prefix)/ThirdParty/Minpack
	cp $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/CopyrightMINPACK.txt $(DESTDIR)$(prefix)/ThirdParty/Minpack
	if [ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ]; then \
	  echo "Installing in dist directory, don't copy MSL"; \
	else \
	  mkdir -p "$(DESTDIR)$(prefix)/ThirdParty/MSL/Modelica"; \
	  mkdir -p "$(DESTDIR)$(prefix)/ThirdParty/MSL/ModelicaServices"; \
	  cd "$(DESTDIR)$(prefix)/ThirdParty/MSL"; \
	  find . -depth -print0 | while read -d $$'\0' -r f ; do if [ ! -e "$(abs_top_srcdir)/ThirdParty/MSL/$${f}" ]; then rm -rf "$${f}"; fi; done; \
	  cd "$(abs_top_srcdir)/ThirdParty/MSL/Modelica"; \
	  find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C "$(DESTDIR)$(prefix)/ThirdParty/MSL/Modelica"; \
	  cd "$(abs_top_srcdir)/ThirdParty/MSL/ModelicaServices"; \
	  find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C "$(DESTDIR)$(prefix)/ThirdParty/MSL/ModelicaServices"; \
	  cd "$(abs_top_srcdir)/ThirdParty/MSL"; \
	  $(CP) Complex.mo "$(DESTDIR)$(prefix)/ThirdParty/MSL"; \
	fi
	mkdir -p $(DESTDIR)$(prefix)/CodeGenTemplates
	mkdir -p $(DESTDIR)$(prefix)/CodeGenTemplates/FMIBase
	cp $(abs_top_srcdir)/RuntimeLibrary/LICENSE_GPL $(DESTDIR)$(prefix)/CodeGenTemplates/LICENSE
	cp -r $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/*.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp -r $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/FMIBase/*.c $(DESTDIR)$(prefix)/CodeGenTemplates/FMIBase
	cp -r $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/FMIBase/*.h $(DESTDIR)$(prefix)/CodeGenTemplates/FMIBase
	cp  $(abs_top_srcdir)/Compiler/ModelicaFMUXBackEnd/templates/*.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	mkdir -p $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML schemas"  || cp  $(abs_top_srcdir)/XML/*.xsd $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML LICENSE"  || cp  $(abs_top_srcdir)/XML/LICENSE $(DESTDIR)$(prefix)/XML
	cp  $(abs_builddir)/version.txt $(DESTDIR)$(prefix)
	chmod ugo+x jm_tests
	cp -p jm_tests $(DESTDIR)$(prefix)/jm_tests
	if [ "$(INSTALL_EXTRA)" ]; then exec "$(INSTALL_EXTRA)" "$(abs_top_srcdir)" "$(DESTDIR)$(prefix)"; fi

bindistdir: install
	rm -rf $(bindistdir)
	mkdir -p $(bindistdir)
	cp $(DESTDIR)$(prefix)/LICENSE $(bindistdir)
	cp $(DESTDIR)$(prefix)/startup.py $(bindistdir)
	cp $(DESTDIR)$(prefix)/version.txt $(bindistdir)
	cp $(DESTDIR)$(prefix)/DefaultOptions.xml $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/CodeGenTemplates $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Makefiles $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Python $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/ThirdParty $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/XML $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/include $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/lib $(bindistdir)
if COMPILE_WITH_IPOPT	
	mkdir -p $(bindistdir)/ThirdParty/Ipopt
# Copy files
	cd $(IPOPT_HOME); find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/Ipopt
# Copy symbolic links
	cd $(IPOPT_HOME); find * -type l |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/Ipopt
endif 

if WITH_MINGW	
	mkdir -p $(bindistdir)/ThirdParty/MinGW
# Copy files
	cd $(MINGW_HOME); find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/MinGW
# Copy symbolic links
	cd $(MINGW_HOME); find * -type l |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/MinGW
endif 

bindist: bindistdir
	tar -cf $(bindistdir).tar $(bindistdir)
	gzip -c $(bindistdir).tar > $(bindistdir).tar.gz
	rm -rf $(bindistdir)
	rm -rf $(bindistdir).tar

test: install
	$(prefix)/jm_tests -i

clean-local: clean-frontends clean-python-packages clean-casadi-interface

clean-casadi-interface: 
	rm -rf $(MC_BUILD)
#	rm -rf $(DESTDIR)$(prefix)/Python/casadi
#	rm -rf $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer
if HAVE_ANT
	cd $(JAVA_CASADI_BUILD_DIR)/ModelicaCompilerCasADi; \
	$(ANT_OPTS) $(ANT) clean ; rm -rf $(MC_CASADI_BUILD)/src/cpp-generated $(MC_CASADI_BUILD)/src/java-generated/ifcasadi 
	cd $(JAVA_CASADI_BUILD_DIR)/OptimicaCompilerCasADi; \
	$(ANT_OPTS) $(ANT) clean ; rm -rf $(OC_CASADI_BUILD)/src/cpp-generated $(OC_CASADI_BUILD)/src/java-generated/ifcasadi 
endif
	

clean-python-packages:
if WITH_SUNDIALS
	if [ -d $(assimulo_build_dir)/Assimulo ]; then \
		cd $(assimulo_build_dir)/Assimulo; \
		python setup.py clean --all --sundials-home=$(SUNDIALS_HOME); \
		cd $(abs_builddir); \
	fi;
	rm -rf $(assimulo_build_dir) || echo  Could not remove $(assimulo_build_dir)
	rm -rf $(assimulo_install_dir) || echo  Could not remove $(assimulo_install_dir)
endif
	-cd $(abs_top_srcdir)/Python/src; \
	python setup_pymodelica.py clean --all 
	-rm -rf $(pymodelica_install_dir) || echo  Could not remove $(pymodelica_install_dir)
	if [ -d $(pyfmi_build_dir)/PyFMI ]; then \
		-cd $(pyfmi_build_dir)/PyFMI; \
		python setup.py  clean --all; \
		cd $(abs_builddir); \
	fi;
	-rm -rf $(pyfmi_build_dir) || echo  Could not remove $(pyfmi_build_dir)
	-rm -rf $(pyfmi_install_dir) || echo  Could not remove $(pyfmi_install_dir)
	-cd $(abs_top_srcdir)/Python/src; \
	python setup_pyjmi.py clean --all 
	-rm -rf $(pyjmi_install_dir)|| echo  Could not remove $(pyjmi_install_dir)

clean-frontends:
if HAVE_ANT
	rm -rf $(JAVA_BUILD_DIR)
endif

docs:
	cd $(abs_top_srcdir); doxygen doc/ModelicaCompiler/modelica_compiler_doxydoc.conf
	cd $(abs_top_srcdir); doxygen doc/OptimicaCompiler/optimica_compiler_doxydoc.conf
	make -C $(abs_top_srcdir)/doc/PyJMI html


.PHONY: modelicacasadi_wrapper ifcasadi install_modelicacasadi_transfer install_modelicacasadi_wrapper
