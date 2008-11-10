AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = vdp

vdp_SOURCES = vdp.c \
               vdp_main.c 

vdp_CFLAGS = -Wall -I../../Jmi
vdp_CXXFLAGS = -Wall -I../../Jmi

# This is just to force automake to choose g++ as
# linker. This is neccesary since libjmiold contains
# C++ code. Notice that dummy.cpp does not exist in
# the source tree.
nodist_EXTRA_vdp_SOURCES = dummy.cpp

vdp_LDADD = ../../Jmi/libjmi.la

#vdp_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)

lib_LTLIBRARIES = libvdp.la
libvdp_la_SOURCES = vdp.c

libvdp_la_LDFLAGS = -no-undefined

nodist_EXTRA_libvdp_la_SOURCES = dummy.cpp

libvdp_la_LIBADD = ../../Jmi/libjmi.la


