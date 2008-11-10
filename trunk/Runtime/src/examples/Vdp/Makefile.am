AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = vdp

vdp_SOURCES = vdp.c \
               vdp_main.c 

AM_CFLAGS = -Wall -I../../Jmi

# This is just to force automake to choose g++ as
# linker. This is neccesary since libjmiold contains
# C++ code. Notice that dummy.cpp does not exist in
# the source tree.
nodist_EXTRA_vdp_SOURCES = dummy.cpp

vdp_LDADD = ../../Jmi/libjmi.la

#vdp_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)
