#
#    Copyright (C) 2009 Modelon AB
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3 as published 
#    by the Free Software Foundation, or optionally, under the terms of the 
#    Common Public License version 1.0 as published by IBM.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License, or the Common Public License, for more details.
#
#    You should have received copies of the GNU General Public License
#    and the Common Public License along with this program.  If not, 
#    see <http://www.gnu.org/licenses/> or 
#    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
#


AUTOMAKE_OPTIONS = foreign

#lib_LTLIBRARIES = libjmi.la \
#                  libjmi_cppad.la

lib_LTLIBRARIES = libjmi.la \
                  libjmi_algorithm.la 

if COMPILE_WITH_CPPAD
lib_LTLIBRARIES += libjmi_cppad.la \
                   libjmi_algorithm_cppad.la
endif 

if COMPILE_WITH_IPOPT
lib_LTLIBRARIES += libjmi_solver.la
if COMPILE_WITH_CPPAD
lib_LTLIBRARIES += libjmi_solver_cppad.la
endif
endif

libjmi_la_SOURCES = jmi.h \
                    jmi_common.h \
                    jmi.c \
                    jmi_common.c \
                    jmi_opt_sim.h 

libjmi_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_algorithm_la_SOURCES = jmi_opt_sim.h \
                              jmi_opt_sim.c \
                              jmi_opt_sim_lp.c

libjmi_algorithm_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_algorithm_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_solver_la_SOURCES = jmi_opt_sim_lp.c \
                           jmi_opt_sim_ipopt.cpp \
                           jmi_TNLP.cpp

libjmi_solver_la_CFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g
libjmi_solver_la_CXXFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_solver_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_cppad_la_SOURCES = jmi.h \
                    jmi_common.c \
                    jmi_cppad.cpp\
                    jmi_common.c 
                   
libjmi_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g

libjmi_algorithm_cppad_la_SOURCES = jmi_opt_sim.h \
                                    jmi_opt_sim.c \
                                    jmi_opt_sim_lp.c
                   
libjmi_algorithm_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_algorithm_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_algorithm_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g
#libjmi_cppad_la_LDFLAGS = -no-undefined 

libjmi_solver_cppad_la_SOURCES = jmi_opt_sim_ipopt.cpp \
                                 jmi_TNLP.cpp
                   
libjmi_solver_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_INC) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_solver_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_INC) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_solver_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g
#libjmi_cppad_la_LDFLAGS = -no-undefined 


include_HEADERS = jmi.h \
                  jmi_common.h \
                  jmi_opt_sim.h \
                  jmi_opt_sim_lp.h 

if COMPILE_WITH_IPOPT
include_HEADERS += jmi_opt_sim_ipopt.h
endif