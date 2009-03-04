# Copyright (C) 2009 Modelon AB
# All Rights reserved
# This file is published under the Common Public License 1.0.


AUTOMAKE_OPTIONS = foreign

bin_PROGRAMS = simple

simple_SOURCES = SimpleExample.hpp SimpleExample.cpp

AM_CPPFLAGS = -I$(IPOPT_INC) \
              -I../../ModelInterface \
              -I../../OptimicaInterface \
              -I../../IpoptInterface 

simple_LDADD =  ../../IpoptInterface/libjmrt.la

simple_LDFLAGS=$(APP_LDFLAGS) $(APP_LIBS)