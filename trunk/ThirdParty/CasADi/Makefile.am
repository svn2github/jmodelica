CASADI_BUILD_DIR=$(abs_builddir)/../../casadi_build

# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(CASADI_BUILD_DIR):
	mkdir -p $(CASADI_BUILD_DIR) && \
	cd $(CASADI_BUILD_DIR) && \
	IPOPT=$(IPOPT_HOME) SUNDIALS=$(SUNDIALS_HOME) cmake $(abs_top_srcdir)/ThirdParty/CasADi/CasADi/

all-local: $(CASADI_BUILD_DIR)
	cd $(CASADI_BUILD_DIR) && make $(AM_MAKEFLAGS) python

check-local:
	cd $(CASADI_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	cd $(CASADI_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

