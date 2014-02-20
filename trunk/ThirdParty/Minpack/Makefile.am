MINPACK_DIR=../../minpack_build

# This is to ensure that the install target of the Minpack
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(MINPACK_DIR):
	mkdir -p $(MINPACK_DIR) && \
	cd $(MINPACK_DIR) && \
	case $(build) in \
	*-cygwin*) \
	cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
  	*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
  	*-apple*) \
	cmake -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
  	*) \
	cmake -DCMAKE_INSTALL_PREFIX:PATH=$(abs_builddir)/../../minpack_install -DCMINPACK_LIB_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/lib -DCMINPACK_INCLUDE_INSTALL_DIR:PATH=$(abs_builddir)/../../minpack_install/include $(abs_top_srcdir)/ThirdParty/Minpack/cminpack-1.3.2/ ;; \
	esac

all-local: $(MINPACK_DIR)
	cd $(MINPACK_DIR) && make $(AM_MAKEFLAGS)

install-exec-local: $(MINPACK_DIR)
	cd $(MINPACK_DIR) && make $(AM_MAKEFLAGS) install

check-local:
	cd $(MINPACK_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(MINPACK_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean


