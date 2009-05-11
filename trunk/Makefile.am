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

#EXTRA_DIST =  $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/ModelicaCompiler.jar

SUBDIRS = JMI/src

all-local:
if HAVE_ANT
#	cd $(abs_top_srcdir)/Compiler/ModelicaFrontEnd; \
#	$(ANT_OPTS) $(ANT)
#	cd $(abs_top_srcdir)/Compiler/OptimicaFrontEnd; \
#	$(ANT_OPTS) $(ANT)
#	cd $(abs_top_srcdir)/Compiler/ModelicaCBackEnd; \
#	$(ANT_OPTS) $(ANT)
#	cd $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd; \
#	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/ModelicaCompiler; \
	$(ANT_OPTS) $(ANT)
endif

install-exec-local:
if HAVE_ANT
	cp $(abs_top_srcdir)/Compiler/ModelicaCompiler/bin/ModelicaCompiler.jar $(prefix)/lib/
endif
	mkdir $(prefix)/Makefiles
	case $(build) in \
	*-cygwin*) \
	cp $(abs_top_srcdir)/JMI/MakeFiles/Makefile.windows $(prefix)/Makefiles/Makefile ;; \
  	*-mingw*) \
	cp $(abs_top_srcdir)/JMI/MakeFiles/Makefile.windows $(prefix)/Makefiles/MakeFile ;; \
  	*-apple*) \
	cp $(abs_top_srcdir)/JMI/MakeFiles/Makefile.macosx $(prefix)/Makefiles/MakeFile ;; \
  	*) \
	cp $(abs_top_srcdir)/JMI/MakeFiles/Makefile.linux $(prefix)/Makefiles/MakeFile ;; \
	esac 

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
endif

docs:
	cd $(srcdir); doxygen doc/JMI/jmi_doxydoc.conf
	cd $(srcdir); doxygen doc/ModelicaFrontEnd/modelica_frontend_doxydoc.conf
	cd $(srcdir); doxygen doc/OptimicaFrontEnd/optimica_frontend_doxydoc.conf