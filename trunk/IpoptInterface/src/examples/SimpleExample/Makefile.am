AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = simple

simple_SOURCES = SimpleExample.hpp SimpleExample.cpp

AM_CPPFLAGS = -I$(IPOPT_INC) \
              -I../../ModelInterface \
              -I../../OptimicaInterface \
              -I../../IpoptInterface 

simple_LDADD =  ../../IpoptInterface/libjmrt.la
