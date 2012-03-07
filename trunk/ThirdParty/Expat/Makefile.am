EXPAT_DIR=expat-2.0.1

# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(abs_builddir)/../../expat_install:
	cd $(EXPAT_DIR) && $(MAKE) $(AM_MAKEFLAGS) install

all-local: $(abs_builddir)/../../expat_install

check-local:
	cd $(EXPAT_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	cd $(EXPAT_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

