CSPARSE_DIR=$(abs_builddir)/csparse_build
CSPARSE_DIR64=$(abs_builddir)/csparse_build64
# This is to ensure that the install target of the Sundials
# make system is run whenever make all is run. This is needed
# in order to trigger a complete install, local in the build
# directory, early in the build process.

$(CSPARSE_DIR):
	mkdir -p $(CSPARSE_DIR)
	cp -r $(abs_top_srcdir)/ThirdParty/CSparse/csparse/* $(CSPARSE_DIR)/
	mkdir -p $(abs_builddir)/../../csparse_install/lib
	mkdir -p $(abs_builddir)/../../csparse_install/include

if JM_WIN64

$(CSPARSE_DIR64):
	mkdir -p $(CSPARSE_DIR64)
	cp -r $(abs_top_srcdir)/ThirdParty/CSparse/csparse/* $(CSPARSE_DIR64)/	
	mkdir -p $(abs_builddir)/../../csparse_install64/lib
	mkdir -p $(abs_builddir)/../../csparse_install64/include


all-local: $(CSPARSE_DIR) $(CSPARSE_DIR64)
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cd $(CSPARSE_DIR) && make $(AM_MAKEFLAGS) CC=gcc TARGET_ARCH=-m32 install DESTDIR= ; \
	cd $(CSPARSE_DIR64) && make $(AM_MAKEFLAGS) CC=gcc TARGET_ARCH=-m64 install DESTDIR= ;; \
	*) \
	cd $(CSPARSE_DIR) && make $(AM_MAKEFLAGS) install DESTDIR= ; \
	cd $(CSPARSE_DIR64) && make $(AM_MAKEFLAGS) install DESTDIR= ;; \
	esac


install-exec-local: $(CSPARSE_DIR) $(CSPARSE_DIR64)
	cp -r $(CSPARSE_DIR)/Lib/libcsparse.a $(abs_builddir)/../../csparse_install/lib/libcsparse.a
	cp -r $(CSPARSE_DIR)/Include/* $(abs_builddir)/../../csparse_install/include/
	cp -r $(CSPARSE_DIR64)/Lib/libcsparse.a $(abs_builddir)/../../csparse_install64/lib/libcsparse.a
	cp -r $(CSPARSE_DIR64)/Include/* $(abs_builddir)/../../csparse_install64/include/


else !JM_WIN64

all-local: $(CSPARSE_DIR)
	case $(build) in \
	*-cygwin*|*-mingw*) \
	cd $(CSPARSE_DIR) && make $(AM_MAKEFLAGS) CC=gcc TARGET_ARCH=-m32 install DESTDIR= ;; \
	*) \
	cd $(CSPARSE_DIR) && make $(AM_MAKEFLAGS) install DESTDIR= ;; \
	esac
	
install-exec-local: $(CSPARSE_DIR)
	cp -r $(CSPARSE_DIR)/Lib/libcsparse.a $(abs_builddir)/../../csparse_install/lib/libcsparse.a
	cp -r $(CSPARSE_DIR)/Include/* $(abs_builddir)/../../csparse_install/include/

endif !JM_WIN64

check-local:
	cd $(CSPARSE_DIR) && $(MAKE) $(AM_MAKEFLAGS) test
if JM_WIN64
	-cd $(CSPARSE_DIR64) && $(MAKE) $(AM_MAKEFLAGS) test
endif

clean-local:
	-cd $(CSPARSE_DIR) && $(MAKE) $(AM_MAKEFLAGS) clean
if JM_WIN64
	-cd $(CSPARSE_DIR64) && $(MAKE) $(AM_MAKEFLAGS) clean
endif
