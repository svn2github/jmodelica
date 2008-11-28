# This automake file creates four items:
# Executables: vdp[.exe] and vdp_cppad[.exe]
# Libraries: vdp.{so|dll} and vdp.{so|dll}

AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = vdp \
               vdp_cppad

vdp_SOURCES = vdp.c \
               vdp_main.c 

vdp_CFLAGS = -Wall -I../../Jmi -DJMI_AD=JMI_AD_NONE

# This is just to force automake to choose g++ as
# linker. This is neccesary since libjmiold contains
# C++ code. Notice that dummy.cpp does not exist in
# the source tree.
#nodist_EXTRA_vdp_SOURCES = dummy.cpp

vdp_LDADD = ../../Jmi/libjmi.la

# The -static-libtool-libs flag is used to create model dll:s and executables
# that do not depend on shared libraries.
vdp_LDFLAGS = -static-libtool-libs

vdp_cppad_SOURCES = vdp.c \
               vdp_cppad_main.cpp 

vdp_cppad_CFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -x c++ 
vdp_cppad_CXXFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD 

vdp_cppad_LDADD = ../../Jmi/libjmi_cppad.la
vdp_cppad_LDFLAGS = -static-libtool-libs

#vdp_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)

lib_LTLIBRARIES = vdp.la \
                  vdp_cppad.la

vdp_la_SOURCES = vdp.c
vdp_la_CFLAGS = -Wall -I../../Jmi -DJMI_AD=JMI_AD_NONE 

# The -module flag makes libtool accept nonstandard so/dll names.
# The -no-undefined flag is needed when building dll:s for Windows
vdp_la_LDFLAGS = -no-undefined  -module
vdp_la_LIBADD = ../../Jmi/libjmi.la
vdp_la_DEPENDENCIES = ../../Jmi/libjmi.la

vdp_cppad_la_SOURCES = vdp.c
vdp_cppad_la_CFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -x c++ -DBOGUS_FLAG=0
vdp_cppad_la_CXXFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -x c++ -DBOGUS_FLAG=0
vdp_cppad_la_LDFLAGS = -no-undefined  -module
vdp_cppad_la_LIBADD = ../../Jmi/libjmi_cppad.la
vdp_cppad_la_DEPENDENCIES = ../../Jmi/libjmi_cppad.la

