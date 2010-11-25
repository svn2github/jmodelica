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
                  libjmi_algorithm.la \
                  libfmi.la

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
                    fmiModelFunctions.h \
                    fmiModelTypes.h \
                    jmi_common.h \
                    jmi.c \
                    jmi_common.c \
                    jmi_newton_solvers.c \
                    jmi_opt_coll.h \
                    jmi_array_common.h \
                    jmi_array_none.h \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinpinv.c \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinpinv.h \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod.c \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod.h \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod_impl.h 

libjmi_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -std=c89 -pedantic
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_algorithm_la_SOURCES = jmi_init_opt.h \
                              jmi_init_opt.c \
                              jmi_opt_coll.h \
                              jmi_opt_coll.c \
                              jmi_opt_coll_radau.c

libjmi_algorithm_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -std=c89 -pedantic
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_algorithm_la_LDFLAGS = -no-undefined -static-libtool-libs

libfmi_la_SOURCES = fmi.h \
                    fmiModelFunctions.h \
                    fmiModelTypes.h \
                    jmi.h \
                    fmi.c \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinpinv.c \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinpinv.h \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod.c \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod.h \
                    $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod_impl.h 

libfmi_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -std=c89 -pedantic
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libfmi_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_solver_la_SOURCES = jmi_opt_coll_radau.c \
                           jmi_opt_coll_ipopt.cpp \
                           jmi_opt_coll_TNLP.cpp \
                           jmi_init_opt_ipopt.cpp \
                           jmi_init_opt_TNLP.cpp

libjmi_solver_la_CFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g -std=c89 -pedantic
libjmi_solver_la_CXXFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_solver_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_cppad_la_SOURCES = jmi.h \
                    fmiModelFunctions.h \
                    fmiModelTypes.h \
                    jmi_common.c \
                    jmi_cppad.cpp\
                    jmi_common.c \
                    jmi_array_common.h \
                    jmi_array_cppad.h
                   
libjmi_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g

libjmi_algorithm_cppad_la_SOURCES = jmi_init_opt.h \
                                    jmi_init_opt.c \
                                    jmi_opt_coll.h \
                                    jmi_opt_coll.c \
                                    jmi_opt_coll_radau.c
                   
libjmi_algorithm_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_algorithm_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_algorithm_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g
#libjmi_cppad_la_LDFLAGS = -no-undefined 

libjmi_solver_cppad_la_SOURCES = jmi_opt_coll_ipopt.cpp \
                                 jmi_opt_coll_TNLP.cpp \
                                 jmi_init_opt_ipopt.cpp \
                                 jmi_init_opt_TNLP.cpp

                   
libjmi_solver_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_HOME) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_solver_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_HOME) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g
libjmi_solver_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g
#libjmi_cppad_la_LDFLAGS = -no-undefined 


include_HEADERS = jmi.h \
                  fmiModelFunctions.h \
                  fmiModelTypes.h \
                  fmi.h \
                  jmi_common.h \
                  jmi_newton_solvers.h \
                  jmi_init_opt.h \
                  jmi_opt_coll.h \
                  jmi_opt_coll_radau.h \
                  jmi_array_common.h \
                  jmi_array_none.h \
                  jmi_array_cppad.h \
                  $(abs_top_srcdir)/Assimulo/src/lib/kinpinv.h \
                  $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod.h \
                  $(abs_top_srcdir)/Assimulo/src/lib/kinsol_jmod_impl.h 

if COMPILE_WITH_IPOPT
include_HEADERS += jmi_opt_coll_ipopt.h
include_HEADERS += jmi_init_opt_ipopt.h
endif
