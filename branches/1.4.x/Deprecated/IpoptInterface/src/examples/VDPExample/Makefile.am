AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = vdpex

vdpex_SOURCES = VDPModel.hpp VDPModel.cpp \
                VDPOptimization.hpp VDPOptimization.cpp

AM_CPPFLAGS = -I$(IPOPT_INC) \
              -I../../ModelInterface \
              -I../../OptimicaInterface \
              -I../../IpoptInterface 

vdpex_LDADD =  ../../IpoptInterface/libjmrt.la

vdpex_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)
