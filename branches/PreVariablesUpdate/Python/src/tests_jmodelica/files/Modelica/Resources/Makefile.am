TESTLIBRARY_BUILD_DIR=$(abs_builddir)/build
TESTLIBRARY_SRC_DIR=$(abs_top_srcdir)/Python/src/tests_jmodelica/files/Modelica/Resources

$(TESTLIBRARY_BUILD_DIR):
	mkdir -p $(TESTLIBRARY_BUILD_DIR) && \
	cd $(TESTLIBRARY_BUILD_DIR) && \
	case $(build) in \
	*-cygwin*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_Fortran_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-mingw*) \
	cmake -G "MSYS Makefiles" -DCMAKE_C_FLAGS="-m32" -DCMAKE_Fortran_FLAGS="-m32" -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*-apple*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	*) \
	cmake -DCMAKE_INSTALL_DIR:PATH=$(prefix) $(TESTLIBRARY_SRC_DIR) -DTOP_SRC=$(abs_top_srcdir) ;; \
	esac

all-local: $(TESTLIBRARY_BUILD_DIR)
	cd $(TESTLIBRARY_BUILD_DIR) && VERBOSE=1 make $(AM_MAKEFLAGS) install

check-local:
	cd $(TESTLIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) test

clean-local:
	-cd $(TESTLIBRARY_BUILD_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean

