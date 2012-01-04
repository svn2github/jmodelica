SUNDIALS_DIR=sundials-2.4.0

# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(abs_builddir)/../../sundials_install:
	cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) install

all-local: $(abs_builddir)/../../sundials_install

check-local:
	cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

