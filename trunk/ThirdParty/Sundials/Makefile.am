SUNDIALS_DIR=../../sundials_build
SUNDIALS_DIR64=../../sundials_build64
# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(SUNDIALS_DIR):
	mkdir -p $(SUNDIALS_DIR) && \
	cd $(SUNDIALS_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32 -mincoming-stack-boundary=2 -fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.5.0/ ;; \
	*-apple*) \
	cmake -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.5.0/ ;; \
	*) \
	cmake -DCMAKE_C_FLAGS="-fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.5.0/ ;; \
	esac

if JM_WIN64

$(SUNDIALS_DIR64):
	mkdir -p $(SUNDIALS_DIR64)
	cd $(SUNDIALS_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64 -fPIC" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../sundials_install64 $(abs_top_srcdir)/ThirdParty/Sundials/sundials-2.5.0/

all-local: $(SUNDIALS_DIR) $(SUNDIALS_DIR64)
	cd $(SUNDIALS_DIR) && make $(AM_MAKEFLAGS) install
	cd $(SUNDIALS_DIR64) && make $(AM_MAKEFLAGS) install

else !JM_WIN64

all-local: $(SUNDIALS_DIR)
	cd $(SUNDIALS_DIR) && make $(AM_MAKEFLAGS) install

endif !JM_WIN64

check-local:
	cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(SUNDIALS_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(SUNDIALS_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
