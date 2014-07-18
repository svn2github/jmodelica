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
	*-cygwin*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-apple*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	esac

$(RUNTIMELIBRARY_BUILD_DIR64):
	case $(build) in \
	*-cygwin*) \
	mkdir -p $(RUNTIMELIBRARY_BUILD_DIR64) && \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-mingw*) \
	mkdir -p $(RUNTIMELIBRARY_BUILD_DIR64) && \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m64" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) -DSUNDIALS_HOME=$(SUNDIALS_HOME) -DTOP_SRC=$(abs_top_srcdir) ;; \
	esac

all-local: $(RUNTIMELIBRARY_BUILD_DIR) $(RUNTIMELIBRARY_BUILD_DIR64)
	cd $(RUNTIMELIBRARY_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install
	case $(build) in \
	*-cygwin*) \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install ;; \
	*-mingw*) \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && VERBOSE=1 make $(AM_MAKEFLAGS) install ;; \
	esac

check-local:
	cd $(RUNTIMELIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
	case $(build) in \
	*-cygwin*) \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test ;; \
	*-mingw*) \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test ;; \
	esac

clean-local:
	cd $(RUNTIMELIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
	case $(build) in \
	*-cygwin*) \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean ;; \
	*-mingw*) \
	cd $(RUNTIMELIBRARY_BUILD_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean ;; \
	esac
