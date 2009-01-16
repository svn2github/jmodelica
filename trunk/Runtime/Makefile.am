
AUTOMAKE_OPTIONS = foreign

EXTRA_DIST = doxydoc/doxydoc.conf

SUBDIRS = src/jmi 

examples: install
	cd examples/Vdp; $(MAKE) all
	cd examples/Vdp_cppad; $(MAKE) all
	
clean-examples: clean
	cd examples/Vdp; $(MAKE) clean
	cd examples/Vdp_cppad; $(MAKE) clean
	
doxydoc:
	cd $(srcdir); doxygen doxydoc/doxydoc.conf