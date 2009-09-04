# Copyright (C) 2009 Modelon AB
# All Rights reserved
# This file is published under the Common Public License 1.0.

AUTOMAKE_OPTIONS = foreign

lib_LTLIBRARIES = libjmrt.la
libjmrt_la_SOURCES = OptimicaTNLP.hpp \
                               OptimicaTNLP.cpp
                 
libjmrt_la_LIBADD = $(JMALLLIBS)
libjmrt_la_DEPENDENCIES = $(JMALLLIBS)

AM_CPPFLAGS = -I$(IPOPT_INC)

include_HEADERS = OptimicaTNLP.hpp 

