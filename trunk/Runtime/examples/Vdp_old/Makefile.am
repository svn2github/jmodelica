AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = vdp

vdp_SOURCES = vdp_dae.c \
              vdp_init.c \
              vdp_opt.c \
              vdp.c \
              vdp_dae_sd.c \
              vdp_init_sd.c \
              vdp_opt_sd.c

#AM_CXXFLAGS = -I$(IPOPT_INC) \
#              -I../../Jmi 

AM_CFLAGS = -I../../Jmi 

# This is just to force automake to choose g++ as
# linker. This is neccesary since libjmiold contains
# C++ code. Notice that dummy.cpp does not exist in
# the source tree.
nodist_EXTRA_vdp_SOURCES = dummy.cpp

vdp_LDADD = ../../Jmi/libjmiold.la

#vdp_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)
