RUNTIMELIBRARY_BUILD_DIR=$(abs_builddir)/build
RUNTIMELIBRARY_BUILD_DIR64=$(abs_builddir)/build64
RUNTIMELIBRARY_SRC_DIR=$(abs_top_srcdir)/RuntimeLibrary

# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(RUNTIMELIBRARY_BUILD_DIR):
	mkdir -p $(RUNTIMELIBRARY_BUILD_DIR) && \
	cd $(RUNTIMELIBRARY_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-apple*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	esac

if JM_WIN64

$(RUNTIMELIBRARY_BUILD_DIR64):
	mkdir -p $(RUNTIMELIBRARY_BUILD_DIR64)
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir)

all-local: $(RUNTIMELIBRARY_BUILD_DIR) $(RUNTIMELIBRARY_BUILD_DIR64)
	cd $(RUNTIMELIBRARY_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install

else !JM_WIN64

all-local: $(RUNTIMELIBRARY_BUILD_DIR64)
	cd $(RUNTIMELIBRARY_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install

endif !JM_WIN64

check-local:
	cd $(RUNTIMELIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
if JM_WIN64
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test
endif

clean-local:
	-cd $(RUNTIMELIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(RUNTIMELIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
