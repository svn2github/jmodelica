FMIL_BUILD_DIR=$(abs_builddir)/../../FMIL_build

# This is to ensure that the install target of the FMI Library
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(FMIL_BUILD_DIR):
	mkdir -p $(FMIL_BUILD_DIR) && \
	cd $(FMIL_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*) \
	cmake -G "MSYS Makefiles" -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
  	*-mingw*) \
	cmake -G "MSYS Makefiles" -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
  	*-apple*) \
	cmake -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
  	*) \
	cmake -DFMILIB_INSTALL_PREFIX:PATH=$(abs_builddir)/../../FMIL_install $(abs_top_srcdir)/external/FMILibrary/FMILibrary/ ;; \
	esac

all-local: $(FMIL_BUILD_DIR)
	cd $(FMIL_BUILD_DIR) && make $(AM_MAKEFLAGS)

install-exec-local: $(FMIL_BUILD_DIR)
	cd $(FMIL_BUILD_DIR) && make $(AM_MAKEFLAGS) install

check-local:
	cd $(FMIL_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(FMIL_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

