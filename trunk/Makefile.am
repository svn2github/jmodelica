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

#EXTRA_DIST = doc/JMI/jmi_doxydoc.conf

SUBDIRS = JMI/src

all-local:
if HAVE_ANT
	cd $(abs_top_srcdir)/Compiler/ModelicaFrontEnd; \
	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/OptimicaFrontEnd; \
	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/ModelicaCBackEnd; \
	$(ANT_OPTS) $(ANT)
	cd $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd; \
	$(ANT_OPTS) $(ANT)
endif

install-exec-local:
if HAVE_ANT
	cp $(abs_top_srcdir)/Compiler/ModelicaFrontEnd/bin/jmodelica.jar lib
	cp $(abs_top_srcdir)/Compiler/OptimicaFrontEnd/bin/optimica.jar lib
	cp $(abs_top_srcdir)/Compiler/ModelicaCBackEnd/bin/jmodelica_c_backend.jar lib
	cp $(abs_top_srcdir)/Compiler/ModelicaXMLBackEnd/bin/jmodelica_xml_backend.jar lib
endif

clean-local: clean-jmi-examples clean-frontends

jmi-examples: install
	cd JMI/examples/Vdp; $(MAKE) all
	cd JMI/examples/Vdp_cppad; $(MAKE) all
	cd JMI/examples/FurutaPendulum; $(MAKE) all
	cd JMI/examples/CSTR; $(MAKE) all

clean-jmi-examples: 
	cd JMI/examples/Vdp; $(MAKE) clean
	cd JMI/examples/Vdp_cppad; $(MAKE) clean
	cd JMI/examples/FurutaPendulum; $(MAKE) clean
	cd JMI/examples/CSTR; $(MAKE) clean

clean-frontends:
if HAVE_ANT
	cd $(abs_top_srcdir)/Compiler/ModelicaFrontEnd; \
	$(ANT_OPTS) $(ANT) clean
	cd $(abs_top_srcdir)/Compiler/OptimicaFrontEnd; \
	$(ANT_OPTS) $(ANT) clean
	cd $(abs_top_srcdir)/Compiler/ModelicaCBackend; \
	$(ANT_OPTS) $(ANT) clean
	cd $(abs_top_srcdir)/Compiler/ModelicaXMLBackend; \
	$(ANT_OPTS) $(ANT) clean
endif

docs:
	cd $(srcdir); doxygen doc/JMI/jmi_doxydoc.conf
	cd $(srcdir); doxygen doc/ModelicaFrontEnd/modelica_frontend_doxydoc.conf
	cd $(srcdir); doxygen doc/OptimicaFrontEnd/optimica_frontend_doxydoc.conf