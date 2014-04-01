CASADI_SRC_DIR=$(abs_top_srcdir)/ThirdParty/CasADi/CasADi/
CASADI_INST_DIR=$(abs_builddir)/../../casadi_install

# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.




$(CASADI_BUILD_DIR):
	mkdir -p $(CASADI_BUILD_DIR) && \
	cd $(CASADI_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -G "MSYS Makefiles"  -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_INST_DIR) $(CASADI_SRC_DIR) ;; \
	*-mingw*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -G "MSYS Makefiles"  -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_INST_DIR) $(CASADI_SRC_DIR) ;; \
	*-apple*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_INST_DIR) $(CASADI_SRC_DIR) ;; \
	*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_INST_DIR) $(CASADI_SRC_DIR) ;; \
	esac


all-local: $(CASADI_BUILD_DIR)
	cd $(CASADI_BUILD_DIR) && make $(AM_MAKEFLAGS) install_python

check-local:
	cd $(CASADI_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	cd $(CASADI_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

