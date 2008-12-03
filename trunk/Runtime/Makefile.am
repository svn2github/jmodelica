
AUTOMAKE_OPTIONS = foreign

SUBDIRS = src/jmi 

examples: install
	cd examples/Vdp; $(MAKE) all
	cd examples/Vdp_cppad; $(MAKE) all
	
clean-examples: clean
	cd examples/Vdp; $(MAKE) clean
	cd examples/Vdp_cppad; $(MAKE) clean
	
