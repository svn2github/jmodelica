AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = simple

simple_SOURCES = SimpleExample.hpp SimpleExample.cpp

AM_CPPFLAGS = -I$(IPOPT_INC) \
              -I../../ModelInterface \
              -I../../OptimicaInterface \
              -I../../IpoptInterface 

simple_LDADD =  ../../IpoptInterface/libjmrt.la

#simple_LDFLAGS = -L$(IPOPT_LIB) -llapack -lblas -lm -lgfortranbegin -lgfortran -lipopt 
#simple_LDFLAGS = -L$(IPOPT_LIB)  $(Ld-lipopt -lm -lgfortranbegin -lgfortran  

