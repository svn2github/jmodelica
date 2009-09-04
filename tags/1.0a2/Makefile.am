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

bindistdir=JModelica.org-$(VERSION)-bin

all-local:
if HAVE_ANT
	cd $(abs_top_srcdir)/Compiler/ModelicaCompiler; \
	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/OptimicaCompiler; \
	$(ANT_OPTS) $(ANT)
endif

install-exec-local:
if HAVE_ANT
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/ModelicaCompiler.jar $(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/util.jar $(prefix)/lib/
	cp $(abs_top_srcdir)/Compiler/OptimicaCompiler/bin/OptimicaCompiler.jar $(prefix)/lib/
endif
	mkdir -p $(prefix)/Makefiles
	case $(build) in \
	*-cygwin*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(prefix)/Makefiles/Makefile ;; \
  	*-mingw*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.windows $(prefix)/Makefiles/MakeFile ;; \
  	*-apple*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.macosx $(prefix)/Makefiles/MakeFile ;; \
  	*) \
	cp $(abs_top_srcdir)/JMI/Makefiles/Makefile.linux $(prefix)/Makefiles/MakeFile ;; \
	esac
	[ -e $(prefix)/Options ] && echo "Options directory exists "|| mkdir $(prefix)/Options
	[ -e $(prefix)/Options/options.xml ] && echo "options.xml exists "|| cp Options/options_tpl.xml $(prefix)/Options/options.xml
	[ -e $(prefix)/Options/options.py ] && echo "options.py exists "|| cp Options/options_tpl.py $(prefix)/Options/options.py
	mkdir -p $(prefix)/Python
	cd $(abs_top_srcdir)/Python/src/; find jmodelica -type f |grep -v /.svn | grep -v .pyc | grep -v ~ |tar c -T - -f - | tar x -C $(prefix)/Python
	[ -e $(prefix)/Python/jm_python.sh ] && echo "jm_python.sh exists "|| cp Python/jm_python.sh $(prefix)/Python/jm_python.sh
	[ -e $(prefix)/Python/jm_ipython.sh ] && echo "jm_ipython.sh exists "|| cp Python/jm_ipython.sh $(prefix)/Python/jm_ipython.sh
	cp $(abs_top_srcdir)/Python/src/startup.py $(prefix)/
	chmod u+x $(prefix)/Python/jm_*.sh
	mkdir -p $(prefix)/ThirdParty
	mkdir -p $(prefix)/ThirdParty/Beaver
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/LICENSE $(prefix)/ThirdParty/Beaver/
	mkdir -p $(prefix)/ThirdParty/Beaver/lib
	cp $(abs_top_srcdir)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver.jar $(prefix)/ThirdParty/Beaver/lib/ 
	mkdir -p $(prefix)/ThirdParty/CppAD
	cp $(CPPAD_HOME)/COPYING $(prefix)/ThirdParty/CppAD
	mkdir -p $(prefix)/ThirdParty/CppAD/cppad	
	cp $(CPPAD_HOME)/cppad/*.h $(prefix)/ThirdParty/CppAD/cppad
	cp $(CPPAD_HOME)/cppad/*.hpp $(prefix)/ThirdParty/CppAD/cppad
	mkdir -p $(prefix)/ThirdParty/CppAD/cppad/local	
	cp $(CPPAD_HOME)/cppad/local/*.hpp $(prefix)/ThirdParty/CppAD/cppad/local
	cd $(abs_top_srcdir)/ThirdParty; find MSL -type f |grep -v /.svn | grep -v ~ |tar c -T - -f - | tar x -C $(prefix)/ThirdParty
	mkdir -p $(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/templates/jmi_modelica_template.c $(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/OptimicaCBackEnd/templates/jmi_optimica_template.c $(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/jmi_modelica_variables_template.xml $(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/templates/jmi_modelica_values_template.xml $(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/OptimicaXMLBackEnd/templates/jmi_optimica_variables_template.xml $(prefix)/CodeGenTemplates
	cp  $(abs_top_srcdir)/Compiler/OptimicaXMLBackEnd/templates/jmi_optimica_problvariables_template.xml $(prefix)/CodeGenTemplates
	mkdir -p $(prefix)/XML
	cp  $(abs_top_srcdir)/XML/*.xsd $(prefix)/XML

bindistdir: install
	rm -rf $(bindistdir)
	mkdir -p $(bindistdir)
	cp -r $(prefix)/CodeGenTemplates $(bindistdir)
	cp -r $(prefix)/MakeFiles $(bindistdir)
	cp -r $(prefix)/Options $(bindistdir)
	cp -r $(prefix)/Python $(bindistdir)
	cp -r $(prefix)/ThirdParty $(bindistdir)
	cp -r $(prefix)/XML $(bindistdir)
	cp -r $(prefix)/include $(bindistdir)
	cp -r $(prefix)/lib $(bindistdir)
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

clean-local: clean-jmi-examples clean-frontends

jmi-examples: install
	cd JMI/examples/Vdp; $(MAKE) all
	cd JMI/examples/Vdp_cppad; $(MAKE) all
	cd JMI/examples/FurutaPendulum; $(MAKE) all
	cd JMI/examples/CSTR; $(MAKE) all
	cd JMI/examples/CSTR2; $(MAKE) all

clean-jmi-examples: 
	cd JMI/examples/Vdp; $(MAKE) clean
	cd JMI/examples/Vdp_cppad; $(MAKE) clean
	cd JMI/examples/FurutaPendulum; $(MAKE) clean
	cd JMI/examples/CSTR; $(MAKE) clean
	cd JMI/examples/CSTR2; $(MAKE) clean

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
