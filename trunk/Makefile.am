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


# EXTRA_DIST =

# SUBDIRS = ThirdParty/Sundials ThirdParty/Zlib ThirdParty/Minizip ThirdParty/Expat JMI/src ThirdParty/Blas ThirdParty/Lapack external/FMILibrary
SUBDIRS = ThirdParty/Sundials JMI/src ThirdParty/Blas ThirdParty/Lapack external/FMILibrary RuntimeLibrary

assimulo_install_dir=$(abs_builddir)/Assimulo_install
pymodelica_install_dir=$(abs_builddir)/pymodelica_install
pyfmi_install_dir=$(abs_builddir)/PyFMI_install
pyjmi_install_dir=$(abs_builddir)/PyJMI_install

bindistdir=JModelica.org-$(VERSION)-bin

casadi:
	cd $(abs_builddir)/ThirdParty/CasADi; \
	make -f Makefile

install_casadi: casadi
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CasADi/lib
	cp $(abs_builddir)/casadi_build/lib/*.* $(DESTDIR)$(prefix)/ThirdParty/CasADi/lib
	mkdir -p $(DESTDIR)$(prefix)/Python/
	cp -r $(abs_builddir)/casadi_install/casadi $(DESTDIR)$(prefix)/Python/
	## temp fix
	cp $(abs_builddir)/casadi_build/swig/casadi.py $(DESTDIR)$(prefix)/Python/casadi

## Install for CasADiInterface, Variables and targets. 
## MC_interface installs the system with Python. 
## If C++ compilation/tests are wanted there is the target MC_interface_cplusplus

MC_INTERFACE=$(abs_top_srcdir)/ModelicaCasADiInterface

export CASADI_HOME=$(abs_top_srcdir)/ThirdParty/CasADi/CasADi
MC_SRC=$(abs_top_srcdir)/Compiler/ModelicaCompilerCasADi
OC_SRC=$(abs_top_srcdir)/Compiler/OptimicaCompilerCasADi

# The modelica casadi interface is built into a build folder
MC_BUILD=$(abs_builddir)/ModelicaCasADiInterfaceBuild
# Jars from the modified modelica and optimica compilers are put into the JModelica folder
MC_COMPILERS_DIR=$(MC_BUILD)/JModelica.org
MC_LIB=$(DESTDIR)$(prefix)/lib/casadi_interface

CASADI_BUILD_DIR=$(abs_builddir)/casadi_build


# The CMake for ModelicaCasADi needs these variables.
export MODELICA_CASADI_HOME= $(MC_INTERFACE)
export MC_BUILD
export IPOPT_HOME
export CASADI_BUILD_DIR
 
casadi_interface: casadi install_casadi $(MC_LIB) modelicacasadi_wrapper $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/__init__.py $(DESTDIR)$(prefix)/Python/modelicacasadi_wrapper/__init__.py $(DESTDIR)$(prefix)/Python/modelicacasadi_transfer/modelica_casadi_transfer_wrapper.py

ifcasadi: casadi
	mkdir -p $(MC_BUILD)/ifcasadi; \
	cd $(MC_BUILD)/ifcasadi; \
	case $(build) in \
	*-cygwin*) \
	cmake $(MC_SRC)/src/swig -G "MSYS Makefiles" ;; \
	*-mingw*) \
	cmake $(MC_SRC)/src/swig -G "MSYS Makefiles" ;; \
	*) \
	cmake $(MC_SRC)/src/swig ;; \
	esac 
	cd $(MC_BUILD)/ifcasadi;  make

$(MC_LIB): $(MC_SRC)/bin/ModelicaCompiler.jar $(OC_SRC)/bin/OptimicaCompiler.jar $(MC_SRC)/bin/util.jar ifcasadi
	rm -rf $(MC_LIB)
	mkdir -p $(MC_LIB)
	cp $(MC_SRC)/bin/ModelicaCompiler.jar $(MC_LIB)
	cp $(OC_SRC)/bin/OptimicaCompiler.jar $(MC_LIB)
	cp $(MC_SRC)/bin/util.jar $(MC_LIB)
	case $(build) in \
	*-cygwin*) \
	cp $(MC_BUILD)/ifcasadi/ifcasadi.dll $(MC_LIB) ;; \
	*-mingw*) \
	cp $(MC_BUILD)/ifcasadi/ifcasadi.dll $(MC_LIB) ;; \
	*) \
	cp $(MC_BUILD)/ifcasadi/libifcasadi.so $(MC_LIB) ;; \
	esac 

mc_modelica: ifcasadi
	cd $(MC_SRC); $(ANT_OPTS) $(ANT)

mc_optimica: ifcasadi
	mkdir -p $(OC_SRC)/src/java-generated
	cp -pr $(MC_SRC)/src/java-generated/casadi $(OC_SRC)/src/java-generated
	cd $(OC_SRC); $(ANT_OPTS) $(ANT)

$(MC_SRC)/bin/ModelicaCompiler.jar: mc_modelica
$(MC_SRC)/bin/util.jar:             mc_modelica

$(OC_SRC)/bin/OptimicaCompiler.jar: mc_optimica
$(OC_SRC)/bin/util.jar:             mc_optimica

$(MC_BUILD)/modelicacasadi_wrapper/swig/modelicacasadi_wrapper.py: modelicacasadi_wrapper

modelicacasadi_wrapper:
	mkdir -p $(MC_BUILD)/modelicacasadi_wrapper; \
	cd $(MC_BUILD)/modelicacasadi_wrapper; \
	case $(build) in \
	*-cygwin*) \
	cmake $(MC_INTERFACE) -G "MSYS Makefiles" ;; \
	*-mingw*) \
	cmake $(MC_INTERFACE) -G "MSYS Makefiles" ;; \
	*) \
	cmake $(MC_INTERFACE) ;; \
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
	
build-python-packages:
if WITH_SUNDIALS
if WITH_SUPERLU
	cd $(abs_top_srcdir)/external/Assimulo; \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --superlu-home=$(SUPERLU_HOME) --blas-home=$(abs_builddir)/ThirdParty/Blas/ --lapack-home=$(abs_builddir)/ThirdParty/Lapack/ --prefix=$(assimulo_install_dir)
endif
endif
if WITH_SUNDIALS
if !WITH_SUPERLU
	cd $(abs_top_srcdir)/external/Assimulo; \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/ThirdParty/Blas/ --lapack-home=$(abs_builddir)/ThirdParty/Lapack/ --prefix=$(assimulo_install_dir)
endif
endif
	cd $(abs_top_srcdir)/Python/src; \
	python setup_pymodelica.py install --prefix=$(pymodelica_install_dir); \
	rm -rf build

	cd $(abs_top_srcdir)/external/PyFMI; \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --prefix=$(pyfmi_install_dir); \
	rm -rf build

	cd $(abs_top_srcdir)/Python/src; \
	python setup_pyjmi.py install --prefix=$(pyjmi_install_dir); \
	rm -rf build

install-python-packages: build-python-packages
	mkdir -p $(DESTDIR)$(prefix)/Python
	cp $(abs_top_srcdir)/Python/src/startup.py $(DESTDIR)$(prefix)/
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
	mkdir -p $(DESTDIR)$(prefix)/bin
	[ -e $(DESTDIR)$(prefix)/bin/jm_python.sh ] && echo "File exists, don't copy jm_python.sh" || cp Python/jm_python.sh $(DESTDIR)$(prefix)/bin/jm_python.sh
	[ -e $(DESTDIR)$(prefix)/bin/jm_ipython.sh  ] && echo "File exists, don't jm_ipython.sh" || cp Python/jm_ipython.sh $(DESTDIR)$(prefix)/bin/jm_ipython.sh
	chmod ugo+x $(DESTDIR)$(prefix)/bin/jm_*.sh

# Paths for Java build
JAVA_BUILD_DIR=$(abs_builddir)/java
COMPILER_DIR=$(abs_top_srcdir)/Compiler
JAVA_MC_ANT_FILE=$(COMPILER_DIR)/ModelicaCompiler/build.xml
JAVA_OC_ANT_FILE=$(COMPILER_DIR)/OptimicaCompiler/build.xml

all-local: build-python-packages
if HAVE_ANT
	mkdir -p $(JAVA_BUILD_DIR)
	cd $(JAVA_BUILD_DIR); \
	$(ANT_OPTS) $(ANT) -f "$(JAVA_MC_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"
	cd $(JAVA_BUILD_DIR); \
	$(ANT_OPTS) $(ANT) -f "$(JAVA_OC_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"
endif
	$(abs_top_srcdir)/get_version.sh $(abs_top_srcdir) > $(abs_builddir)/version.txt
	mkdir -p $(abs_builddir)/Options
	$(abs_top_srcdir)/run_java.sh org.jmodelica.util.OptionRegistry $(abs_builddir)/Options/options.xml

install-exec-local: install-python-packages
if HAVE_ANT
	cp $(JAVA_BUILD_DIR)/bin/ModelicaCompiler.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/util.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/OptimicaCompiler.jar $(DESTDIR)$(prefix)/lib/
endif
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/LICENSE $(DESTDIR)$(prefix)/ 
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/JMI/LICENSE_CPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/include/
	cp $(abs_top_srcdir)/JMI/LICENSE_CPL $(DESTDIR)$(prefix)/include/
	mkdir -p $(DESTDIR)$(prefix)/Makefiles
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/Makefiles/LICENSE
#	case $(build) in \
#	*-cygwin*) \
#	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/Makefile ;; \
#  	*-mingw*) \
#	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
#  	*-apple*) \
#	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.macosx $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
#  	*) \
#	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.linux $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
#	esac
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

if WITH_MINGW
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/pthreads/lib
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/pthreads/include
	cp $(abs_top_srcdir)/ThirdParty/pthreads/lib/win32/libpthreadGC2-2-9-1.a $(DESTDIR)$(prefix)/ThirdParty/pthreads/lib
	cp $(abs_top_srcdir)/ThirdParty/pthreads/include/*.h $(DESTDIR)$(prefix)/ThirdParty/pthreads/include
endif

	mkdir -p $(DESTDIR)$(prefix)/Options
	cp $(abs_builddir)/Options/options.xml $(DESTDIR)$(prefix)/Options/options.xml
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/LICENSE $(DESTDIR)$(prefix)/ThirdParty/Beaver/
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver-rt.jar $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib/ 
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Sundials	
	cp -r $(SUNDIALS_HOME)/* $(DESTDIR)$(prefix)/ThirdParty/Sundials
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CppAD
	cp $(CPPAD_HOME)/COPYING $(DESTDIR)$(prefix)/ThirdParty/CppAD
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad	
	cp $(CPPAD_HOME)/cppad/*.h $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad
	cp $(CPPAD_HOME)/cppad/*.hpp $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad/local	
	cp $(CPPAD_HOME)/cppad/local/*.hpp $(DESTDIR)$(prefix)/ThirdParty/CppAD/cppad/local
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy MSL" || cd $(abs_top_srcdir)/ThirdParty; find MSL -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/ThirdParty
	mkdir -p $(DESTDIR)$(prefix)/CodeGenTemplates
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/CodeGenTemplates/LICENSE
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/jmi_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi1_me_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi1_cs_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi2_master_modelica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi_code_gen_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi2_functions_common_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi2_functions_me_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/fmi2_functions_cs_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/OptimicaCBackEnd/templates/jmi_optimica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaFMUXBackEnd/templates/*.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	mkdir -p $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML schemas"  || cp  $(abs_top_srcdir)/XML/*.xsd $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML LICENSE"  || cp  $(abs_top_srcdir)/XML/LICENSE $(DESTDIR)$(prefix)/XML
	cp  $(abs_builddir)/version.txt $(DESTDIR)$(prefix)
	cp jm_tests $(DESTDIR)$(prefix)/jm_tests
	chmod ugo+x $(DESTDIR)$(prefix)/jm_tests

bindistdir: install
	rm -rf $(bindistdir)
	mkdir -p $(bindistdir)
	cp $(DESTDIR)$(prefix)/LICENSE $(bindistdir)
	cp $(DESTDIR)$(prefix)/startup.py $(bindistdir)
	cp $(DESTDIR)$(prefix)/version.txt $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/CodeGenTemplates $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Makefiles $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Options $(bindistdir)
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
	cd $(abs_top_srcdir)/Compiler/ModelicaCompilerCasADi; \
	$(ANT_OPTS) $(ANT) clean ; rm -rf $(MC_SRC)/src/cpp-generated $(MC_SRC)/src/java-generated/casadi
	cd $(abs_top_srcdir)/Compiler/OptimicaCompilerCasADi; \
	$(ANT_OPTS) $(ANT) clean ; rm -rf $(OC_SRC)/src/cpp-generated $(OC_SRC)/src/java-generated/casadi
endif
	

clean-python-packages:
if WITH_SUNDIALS
	cd $(abs_top_srcdir)/external/Assimulo; \
	python setup.py clean --all --sundials-home=$(SUNDIALS_HOME) 
	rm -rf $(assimulo_install_dir) || echo  Could not remove $(assimulo_install_dir)
endif
	-cd $(abs_top_srcdir)/Python/src; \
	python setup_pymodelica.py clean --all 
	-rm -rf $(pymodelica_install_dir) || echo  Could not remove $(pymodelica_install_dir)
	-cd $(abs_top_srcdir)/external/PyFMI; \
	python setup.py  clean --all 
	-rm -rf $(pyfmi_install_dir) || echo  Could not remove $(pyfmi_install_dir)
	-cd $(abs_top_srcdir)/Python/src; \
	python setup_pyjmi.py clean --all 
	-rm -rf $(pyjmi_install_dir)|| echo  Could not remove $(pyjmi_install_dir)

clean-frontends:
if HAVE_ANT
	rm -rf $(JAVA_BUILD_DIR)
endif

docs:
	cd $(abs_top_srcdir); doxygen doc/JMI/jmi_doxydoc.conf
	cd $(abs_top_srcdir); doxygen doc/ModelicaCompiler/modelica_compiler_doxydoc.conf
	cd $(abs_top_srcdir); doxygen doc/OptimicaCompiler/optimica_compiler_doxydoc.conf
	make -C $(abs_top_srcdir)/doc/PyJMI html

docbook-docs:
	cd docbook/UsersGuide; $(MAKE) all


.PHONY: modelicacasadi_wrapper ifcasadi install_modelicacasadi_transfer install_modelicacasadi_wrapper
