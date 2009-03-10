# 
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the Common Public License as published by
#    IBM, version 1.0 of the License.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY. See the Common Public License for more details.
#
#    You should have received a copy of the Common Public License
#    along with this program.  If not, see
#     <http://www.ibm.com/developerworks/library/os-cpl.html/>.


AUTOMAKE_OPTIONS = foreign

#lib_LTLIBRARIES = libjmi.la \
#                  libjmi_cppad.la

lib_LTLIBRARIES = libjmi.la \
                  libjmi_cppad.la


libjmi_la_SOURCES = jmi.h \
                    jmi_common.h \
                    jmi.c \
                    jmi_common.c \
                    jmi_opt_sim.h \
                    jmi_opt_sim.c \
                    jmi_opt_sim_lp.c \
                    jmi_opt_sim_ipopt.c

libjmi_la_CFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_la_LDFLAGS = -no-undefined -static-libtool-libs

#libjmi_la_LIBADD = $(JMALLLIBS)
#libjmi_la_DEPENDENCIES = $(JMALLLIBS)

#AM_CPPFLAGS = -I$(IPOPT_INC)

libjmi_cppad_la_SOURCES = jmi.h \
                    jmi_common.c \
                    jmi_cppad.cpp\
                    jmi_common.c \
                    jmi_opt_sim.h \
                    jmi_opt_sim.c \
                    jmi_opt_sim_lp.c \
                    jmi_opt_sim_ipopt.c
                   
libjmi_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_INC) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g
#libjmi_cppad_la_LDFLAGS = -no-undefined 

include_HEADERS = jmi.h \
                  jmi_common.h \
                  jmi_opt_sim.h \
                  jmi_opt_sim_lp.h \
                  jmi_opt_sim_ipopt.h

