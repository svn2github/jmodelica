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

vdp_cppad_SOURCES = vdp.c \
               vdp_cppad_main.cpp 

nodist_EXTRA_vdp_cppad_SOURCES = dummy.cpp

vdp_cppad_CFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -x c++ 
vdp_cppad_CXXFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD 

vdp_cppad_LDADD = ../../Jmi/libjmi_cppad.la

#vdp_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)

lib_LTLIBRARIES = libvdp.la \
                  libvdp_cppad.la

libvdp_la_SOURCES = vdp.c
libvdp_la_CFLAGS = -Wall -I../../Jmi -DJMI_AD=JMI_AD_NONE 
libvdp_la_LDFLAGS = -no-undefined
libvdp_la_LIBADD = ../../Jmi/libjmi.la

libvdp_cppad_la_SOURCES = vdp.c
libvdp_cppad_la_CXXFLAGS = -Wall -I../../Jmi -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -x c++ 
libvdp_cppad_la_LDFLAGS = -no-undefined
nodist_EXTRA_libvdp_cppad_la_SOURCES = dummy.cpp
libvdp_cppad_la_LIBADD = ../../Jmi/libjmi_cppad.la


