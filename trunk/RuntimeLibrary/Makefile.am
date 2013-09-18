RUNTIMELIBRARY_BUILD_DIR=$(abs_builddir)/../RuntimeLibrary/build
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
	cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) ;; \
	*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) ;; \
	*-apple*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) ;; \
	*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(RUNTIMELIBRARY_SRC_DIR) ;; \
	esac

all-local: $(RUNTIMELIBRARY_BUILD_DIR)
	cd $(RUNTIMELIBRARY_BUILD_DIR) && make $(AM_MAKEFLAGS) install

check-local:
	cd $(RUNTIMELIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	cd $(RUNTIMELIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

