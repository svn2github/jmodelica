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

EXTRA_DIST = doxydoc/doxydoc.conf

SUBDIRS = src/jmi 

examples: install
	cd examples/Vdp; $(MAKE) all
	cd examples/Vdp_cppad; $(MAKE) all
	
clean-examples: 
	cd examples/Vdp; $(MAKE) clean
	cd examples/Vdp_cppad; $(MAKE) clean
	
doxydoc:
	cd $(srcdir); doxygen doxydoc/doxydoc.conf