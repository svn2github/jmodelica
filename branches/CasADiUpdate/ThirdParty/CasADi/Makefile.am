CASADI_SRC_DIR=$(abs_top_srcdir)/ThirdParty/CasADi/CasADi/
CASADI_PYTHON_INST_DIR=$(abs_builddir)/../../casadi_install
CASADI_INST_DIR=$(DESTDIR)$(prefix)/ThirdParty/CasADi
CMAKE_PYTHON_LIBRARY=
CMAKE_PYTHON_INCLUDE_DIR=

# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(CASADI_BUILD_DIR):
	if [ "$(CMAKE_PYTHON_LIBRARY)" ] && [ "$(CMAKE_PYTHON_INCLUDE_DIR)" ]; then \
		CMAKE_EXTRA_ARGS="-DPYTHON_LIBRARY=$(CMAKE_PYTHON_LIBRARY) -DPYTHON_INCLUDE_DIR=$(CMAKE_PYTHON_INCLUDE_DIR)"; \
	else \
		CMAKE_EXTRA_ARGS=""; \
	fi; \
	mkdir -p $(CASADI_BUILD_DIR) && \
	cd $(CASADI_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -G "MSYS Makefiles"  -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_PYTHON_INST_DIR) -DPython_ADDITIONAL_VERSIONS="2.7;2.6;2.5;2.4" -DCMAKE_INSTALL_PREFIX=$(CASADI_INST_DIR) $${CMAKE_EXTRA_ARGS} $(CASADI_SRC_DIR) ;; \
	*-mingw*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -G "MSYS Makefiles"  -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_PYTHON_INST_DIR) -DPython_ADDITIONAL_VERSIONS="2.7;2.6;2.5;2.4" -DCMAKE_INSTALL_PREFIX=$(CASADI_INST_DIR) $${CMAKE_EXTRA_ARGS} $(CASADI_SRC_DIR) ;; \
	*-apple*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_PYTHON_INST_DIR) -DPython_ADDITIONAL_VERSIONS="2.7;2.6;2.5;2.4" -DCMAKE_INSTALL_PREFIX=$(CASADI_INST_DIR) $${CMAKE_EXTRA_ARGS} $(CASADI_SRC_DIR) ;; \
	*) \
	PKG_CONFIG_PATH=$(IPOPT_HOME)/lib/pkgconfig cmake -DENABLE_SHARED=ON -DENABLE_STATIC=OFF -DPYTHON_PREFIX=$(CASADI_PYTHON_INST_DIR) -DPython_ADDITIONAL_VERSIONS="2.7;2.6;2.5;2.4" -DCMAKE_INSTALL_PREFIX=$(CASADI_INST_DIR) $${CMAKE_EXTRA_ARGS} $(CASADI_SRC_DIR) ;; \
	esac


all-local: $(CASADI_BUILD_DIR)
	cd $(CASADI_BUILD_DIR) && make $(AM_MAKEFLAGS) install_python

install:
	cd $(CASADI_BUILD_DIR) && make $(AM_MAKEFLAGS) install

check-local:
	cd $(CASADI_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	cd $(CASADI_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

