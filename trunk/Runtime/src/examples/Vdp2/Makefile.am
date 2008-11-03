AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = vdp2

vdp2_SOURCES = vdp.c \
               vdp_main.c 

#AM_CXXFLAGS = -I$(IPOPT_INC) \
#              -I../../Jmi2 

AM_CFLAGS = -I../../Jmi2 

# This is just to force automake to choose g++ as
# linker. This is neccesary since libjmiold contains
# C++ code. Notice that dummy.cpp does not exist in
# the source tree.
nodist_EXTRA_vdp2_SOURCES = dummy.cpp

vdp2_LDADD = ../../Jmi2/libjmi.la

#vdp_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)
