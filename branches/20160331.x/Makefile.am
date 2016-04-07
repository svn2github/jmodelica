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

# SUBDIRS = ThirdParty/Sundials ThirdParty/Zlib ThirdParty/Minizip ThirdParty/Expat ThirdParty/Blas ThirdParty/Lapack external/FMILibrary
SUBDIRS = ThirdParty/Sundials ThirdParty/Minpack ThirdParty/Blas ThirdParty/Lapack external/FMILibrary RuntimeLibrary

assimulo_install_dir=$(abs_builddir)/Assimulo_install
pymodelica_install_dir=$(abs_builddir)/pymodelica_install
pyfmi_install_dir=$(abs_builddir)/PyFMI_install

bindistdir=JModelica.org-$(VERSION)-bin

build-python-packages:
if WITH_SUNDIALS
if WITH_SUPERLU
	cd $(abs_top_srcdir)/external/Assimulo; \
	case $(build) in \
	*-cygwin*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --superlu-home=$(SUPERLU_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*-mingw*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --superlu-home=$(SUPERLU_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" --no-msvcr="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --superlu-home=$(SUPERLU_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --prefix=$(assimulo_install_dir) ;; \
	esac
endif
endif
if WITH_SUNDIALS
if !WITH_SUPERLU
	cd $(abs_top_srcdir)/external/Assimulo; \
	case $(build) in \
	*-cygwin*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*-mingw*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --force-32bit="true" --no-msvcr="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(assimulo_install_dir) ;; \
	*) \
	python setup.py install --sundials-home=$(SUNDIALS_HOME) --blas-home=$(abs_builddir)/blas_install/ --lapack-home=$(abs_builddir)/lapack_install/ --prefix=$(assimulo_install_dir) ;; \
	esac
endif
endif
	cd $(abs_top_srcdir)/Python/src; \
	python setup_pymodelica.py install --prefix=$(pymodelica_install_dir); \
	rm -rf build

	cd $(abs_top_srcdir)/external/PyFMI; \
	case $(build) in \
	*-cygwin*) \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --force-32bit="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(pyfmi_install_dir) ;; \
	*-mingw*) \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --force-32bit="true" --no-msvcr="true" --extra-c-flags="-mincoming-stack-boundary=2" --prefix=$(pyfmi_install_dir) ;; \
	*) \
	python setup.py install --fmil-home=$(abs_builddir)/FMIL_install/ --prefix=$(pyfmi_install_dir) ;; \
	esac
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
	if [ -e $(pyfmi_install_dir)/$${pkgdir}/site-packages/ ]; \
	then \
	cd $(pyfmi_install_dir)/$${pkgdir}/site-packages/; \
	find pyfmi -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi; \
	done

# Hooks for extra build or install actions. Must be empty or the path of a shell script to execute. 
# Both scripts will get the source directory as the first argument and the install directory as the second.
BUILD_EXTRA=
INSTALL_EXTRA=

# Paths for Java build
JAVA_BUILD_DIR=$(abs_builddir)/java
COMPILER_DIR=$(abs_top_srcdir)/Compiler
JAVA_MC_ANT_FILE=$(COMPILER_DIR)/ModelicaCompiler/build.xml

all-local: build-python-packages build-compiler

build-compiler:
if HAVE_ANT
	mkdir -p $(JAVA_BUILD_DIR)
	cd $(JAVA_BUILD_DIR); \
	$(ANT_OPTS) $(ANT) -f "$(JAVA_MC_ANT_FILE)" "-Dcompiler=$(COMPILER_DIR)"
	java -cp "$(JAVA_BUILD_DIR)/bin/ModelicaCompiler.jar:$(JAVA_BUILD_DIR)/bin/util.jar:$(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver-rt.jar" org.jmodelica.modelica.compiler.ModelicaCompiler\$$OptionExporter -x "$(abs_builddir)/DefaultOptions.xml" 
endif
	if [ "$(BUILD_EXTRA)" ]; then exec "$(BUILD_EXTRA)" "$(abs_top_srcdir)" "$(DESTDIR)$(prefix)"; fi

install-exec-local: install-python-packages
if HAVE_ANT
	cp $(JAVA_BUILD_DIR)/bin/ModelicaCompiler.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/util.jar $(DESTDIR)$(prefix)/lib/
	cp $(JAVA_BUILD_DIR)/bin/separateProcess.jar $(DESTDIR)$(prefix)/lib/
endif
	mkdir -p $(DESTDIR)$(prefix)/Makefiles
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
	cp $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.5.0/LICENSE $(DESTDIR)$(prefix)/ThirdParty/Sundials
if JM_WIN64
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Sundials/lib64
	cp -r $(SUNDIALS_HOME)64/lib/* $(DESTDIR)$(prefix)/ThirdParty/Sundials/lib64
endif
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Minpack	
	cp -r $(DESTDIR)$(MINPACK_HOME)/* $(DESTDIR)$(prefix)/ThirdParty/Minpack
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
	cp -r $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/*.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp -r $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/FMIBase/*.c $(DESTDIR)$(prefix)/CodeGenTemplates/FMIBase
	cp -r $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/FMIBase/*.h $(DESTDIR)$(prefix)/CodeGenTemplates/FMIBase
	cp  $(abs_top_srcdir)/Compiler/ModelicaFMUXBackEnd/templates/*.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	if [ "$(INSTALL_EXTRA)" ]; then exec "$(INSTALL_EXTRA)" "$(abs_top_srcdir)" "$(DESTDIR)$(prefix)"; fi

bindistdir: install
	rm -rf $(bindistdir)
	mkdir -p $(bindistdir)
	cp $(DESTDIR)$(prefix)/DefaultOptions.xml $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/CodeGenTemplates $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Makefiles $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/Python $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/ThirdParty $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/include $(bindistdir)
	cp -r $(DESTDIR)$(prefix)/lib $(bindistdir)

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


clean-local: clean-frontends clean-python-packages


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

clean-frontends:
if HAVE_ANT
	rm -rf $(JAVA_BUILD_DIR)
endif
