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

# EXTRA_DIST =

SUBDIRS = JMI/src

assimulo_install_dir=$(abs_builddir)/Assimulo_install

bindistdir=JModelica.org-$(VERSION)-bin

all-local:
if HAVE_ANT
	cd $(abs_top_srcdir)/Compiler/ModelicaCompiler; \
	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/OptimicaCompiler; \
	$(ANT_OPTS) $(ANT)
endif
if WITH_SUNDIALS
	cd $(abs_top_srcdir)/Assimulo; \
	python setup_source.py install --sundials-home=$(SUNDIALS_HOME) --prefix=$(assimulo_install_dir)
endif

install-exec-local:
if HAVE_ANT
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/ModelicaCompiler.jar $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/util.jar $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/graphs.jar $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/OptimicaCompiler/bin/OptimicaCompiler.jar $(DESTDIR)$(prefix)/lib/
endif
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/LICENSE $(DESTDIR)$(prefix)/ 
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/JMI/LICENSE_CPL $(DESTDIR)$(prefix)/lib/
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/include/
	cp $(abs_top_srcdir)/JMI/LICENSE_CPL $(DESTDIR)$(prefix)/include/
	mkdir -p $(DESTDIR)$(prefix)/Makefiles
	cp $(abs_top_srcdir)/JMI/LICENSE_GPL $(DESTDIR)$(prefix)/Makefiles/LICENSE
	case $(build) in \
	*-cygwin*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/Makefile ;; \
  	*-mingw*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
  	*-apple*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.macosx $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
  	*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.linux $(DESTDIR)$(prefix)/Makefiles/MakeFile ;; \
	esac
	mkdir -p $(DESTDIR)$(prefix)/Options
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy options file" || cp $(abs_top_srcdir)/Options/options.xml $(DESTDIR)$(prefix)/Options/options.xml
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/Options/LICENSE $(DESTDIR)$(prefix)/Options/LICENSE
	mkdir -p $(DESTDIR)$(prefix)/Python
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy LICENSE file" || cp $(abs_top_srcdir)/Python/LICENSE $(DESTDIR)$(prefix)/Python
	cd $(abs_top_srcdir)/Python/src/; find jmodelica -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python
if WITH_SUNDIALS
	if [ -e $(assimulo_install_dir)/lib/python2.5/site-packages/ ]; \
	then \
	cd $(assimulo_install_dir)/lib/python2.5/site-packages/; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi
	if [ -e $(assimulo_install_dir)/lib/python2.6/site-packages/ ];\
	then \
	cd $(assimulo_install_dir)/lib/python2.6/site-packages/; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	else \
	cd $(assimulo_install_dir)/Lib/site-packages/; \
	find Assimulo -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(DESTDIR)$(prefix)/Python; \
	fi
endif 
	mkdir -p $(DESTDIR)$(prefix)/bin
	[ -e $(DESTDIR)$(prefix)/bin/jm_python.sh ] && echo "File exists, don't copy jm_python.sh" || cp Python/jm_python.sh $(DESTDIR)$(prefix)/bin/jm_python.sh
	[ -e $(DESTDIR)$(prefix)/bin/jm_ipython.sh  ] && echo "File exists, don't jm_ipython.sh" || cp Python/jm_ipython.sh $(DESTDIR)$(prefix)/bin/jm_ipython.sh
	cp $(abs_top_srcdir)/Python/src/startup.py $(DESTDIR)$(prefix)/
	chmod ugo+x $(DESTDIR)$(prefix)/bin/jm_*.sh
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/LICENSE $(DESTDIR)$(prefix)/ThirdParty/Beaver/
	mkdir -p $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver.jar $(DESTDIR)$(prefix)/ThirdParty/Beaver/lib/ 
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
	cp  $(abs_top_srcdir)/Compiler/OptimicaCBackEnd/templates/jmi_optimica_template.c $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/fmi_model_description.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/fmi_extended_model_description.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/jmodelica_model_description.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/jmodelica_model_values.tpl $(DESTDIR)$(prefix)/CodeGenTemplates
	mkdir -p $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML schemas"  || cp  $(abs_top_srcdir)/XML/*.xsd $(DESTDIR)$(prefix)/XML
	[ $(abs_top_srcdir) == $(DESTDIR)$(prefix) ] && echo "Installing in dist directory, don't copy XML LICENSE"  || cp  $(abs_top_srcdir)/XML/LICENSE $(DESTDIR)$(prefix)/XML
	cp  $(abs_top_srcdir)/version.txt $(DESTDIR)$(prefix)
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

if WITH_SUNDIALS	
	mkdir -p $(bindistdir)/ThirdParty/SUNDIALS
# Copy files
	cd $(SUNDIALS_HOME); find * -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/SUNDIALS
# Copy symbolic links
	cd $(SUNDIALS_HOME); find * -type l |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(abs_builddir)/$(bindistdir)/ThirdParty/SUNDIALS
endif 

bindist: bindistdir
	tar -cf $(bindistdir).tar $(bindistdir)
	gzip -c $(bindistdir).tar > $(bindistdir).tar.gz
	rm -rf $(bindistdir)
	rm -rf $(bindistdir).tar

test: install
	$(prefix)/jm_tests -i

clean-local: clean-frontends clean-assimulo

# jmi-examples: install
# 	cd JMI/examples/Vdp; $(MAKE) all
# 	cd JMI/examples/Vdp_cppad; $(MAKE) all
# 	cd JMI/examples/FurutaPendulum; $(MAKE) all
# 	cd JMI/examples/CSTR; $(MAKE) all
# 	cd JMI/examples/CSTR2; $(MAKE) all

# clean-jmi-examples: 
# 	cd JMI/examples/Vdp; $(MAKE) clean
# 	cd JMI/examples/Vdp_cppad; $(MAKE) clean
# 	cd JMI/examples/FurutaPendulum; $(MAKE) clean
# 	cd JMI/examples/CSTR; $(MAKE) clean
# 	cd JMI/examples/CSTR2; $(MAKE) clean

clean-assimulo:
if WITH_SUNDIALS
	cd $(abs_top_srcdir)/Assimulo; \
	python setup_source.py clean --all --sundials-home=$(SUNDIALS_HOME) 
	rm -rf $(assimulo_install_dir)
endif

clean-frontends:
if HAVE_ANT
#	cd $(abs_top_srcdir)/Compiler/ModelicaFrontEnd; \
#	$(ANT_OPTS) $(ANT) clean
#	cd $(abs_top_srcdir)/Compiler/OptimicaFrontEnd; \
#	$(ANT_OPTS) $(ANT) clean
#	cd $(abs_top_srcdir)/Compiler/ModelicaCBackend; \
#	$(ANT_OPTS) $(ANT) clean
#	cd $(abs_top_srcdir)/Compiler/ModelicaXMLBackend; \
#	$(ANT_OPTS) $(ANT) clean
	cd $(abs_top_srcdir)/Compiler/ModelicaCompiler; \
	$(ANT_OPTS) $(ANT) clean
	cd $(abs_top_srcdir)/Compiler/OptimicaCompiler; \
	$(ANT_OPTS) $(ANT) clean
endif

docs:
	cd $(srcdir); doxygen doc/JMI/jmi_doxydoc.conf
#	cd $(srcdir); doxygen doc/ModelicaFrontEnd/modelica_frontend_doxydoc.conf
#	cd $(srcdir); doxygen doc/OptimicaFrontEnd/optimica_frontend_doxydoc.conf
	cd $(srcdir); doxygen doc/ModelicaCompiler/modelica_compiler_doxydoc.conf
	cd $(srcdir); doxygen doc/OptimicaCompiler/optimica_compiler_doxydoc.conf
	cd $(srcdir); doxygen doc/PyJMI/pyjmi_doxydoc.conf

docbook-docs:
	cd docbook/UsersGuide; $(MAKE) all

