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
                  libfmi.la \
                  libfmi_cs.la \
                  libModelicaExternalC.la

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
                    fmi1_functions.h \
                    fmi1_types.h \
                    jmi_common.h \
                    jmi_common.c \
                    jmi.c \
                    jmi_global.h \
                    jmi_global.c \
                    jmi_simple_newton.h \
                    jmi_simple_newton.c \
                    jmi_block_residual.h \
                    jmi_block_residual.c \
                    jmi_kinsol_solver.h \
                    jmi_kinsol_solver.c \
                    jmi_linear_solver.h \
                    jmi_linear_solver.c \
                    jmi_ode_solver.c \
                    jmi_ode_solver.h \
                    jmi_ode_cvode.h \
                    jmi_ode_cvode.c \
                    jmi_ode_euler.h \
                    jmi_ode_euler.c \
                    jmi_opt_coll.h \
                    jmi_array_common.h \
                    jmi_array_none.h \
                    jmi_array_none.c \
                    jmi_util.h \
                    jmi_util.c \
                    jmi_log.h \
                    jmi_log.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod_impl.h 

libjmi_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -I$(abs_top_srcdir)/external/Assimulo/src/lib -std=c89 -pedantic
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_algorithm_la_SOURCES = jmi_init_opt.h \
                              jmi_init_opt.c \
                              jmi_opt_coll.h \
                              jmi_opt_coll.c \
                              jmi_opt_coll_radau.c

libjmi_algorithm_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -std=c89 -pedantic
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_algorithm_la_LDFLAGS = -no-undefined -static-libtool-libs

libfmi_la_SOURCES = fmi1_me.h \
                    fmiModelFunctions.h \
                    fmiModelTypes.h \
                    jmi.h \
                    fmi1_me.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod_impl.h 

libfmi_cs_la_SOURCES = fmi1_cs.h \
                    fmiCSModelFunctions.h \
                    fmiCSPlatformTypes.h \
                    jmi.h \
                    fmi1_cs.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod_impl.h 


libfmi_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -std=c89 -pedantic
libfmi_la_LDFLAGS = -no-undefined -static-libtool-libs

libfmi_cs_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -std=c89 -pedantic
libfmi_cs_la_LDFLAGS = -no-undefined -static-libtool-libs

#libModelicaExternalC_la_SOURCES =  $(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/ModelicaInternal.c \
#	                           $(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/ModelicaStrings.c \
#                                   $(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/ModelicaTables.h \
#                                   ModelicaTables_JM.c \
#                                   jmtables.h \
#                                   jmtables.c \
#                                   ModelicaUtilities.h \
#                                   ModelicaUtilities.c

libModelicaExternalC_la_SOURCES =  ModelicaUtilities.h \
                                   ModelicaUtilities.c \
                                   jmi_global.h \
                                   jmi_global.c \
                                   $(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/ModelicaInternal.c \
	                           $(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/ModelicaStrings.c

libModelicaExternalC_la_CFLAGS = -Wall -g -std=c89 -pedantic -I$(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/
if WITH_TABLES
libModelicaExternalC_la_SOURCES +=  ModelicaTables_JM.c \
                                    jmtables.h \
                                    jmtables.c
libModelicaExternalC_la_CFLAGS += -I$(TABLES_HOME)/include
endif

# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libModelicaExternalC_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_solver_la_SOURCES = jmi_opt_coll_radau.c \
                           jmi_opt_coll_ipopt.cpp \
                           jmi_opt_coll_TNLP.cpp \
                           jmi_init_opt_ipopt.cpp \
                           jmi_init_opt_TNLP.cpp

libjmi_solver_la_CFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include -std=c89 -pedantic
libjmi_solver_la_CXXFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE -g -I$(SUNDIALS_HOME)/include
# Don't build shared libraries of libjmi and libjmicppad. This is not
# really needed, and also (more importantly perhaps) I cannot force
# static inclusion of the runtime libraries when creating model so:s.
libjmi_solver_la_LDFLAGS = -no-undefined -static-libtool-libs

libjmi_cppad_la_SOURCES = jmi.h \
                    jmi_common.c \
                    jmi_common.h \
                    jmi_global.h \
                    jmi_global.c \
                    jmi_block_residual.h \
                    jmi_block_residual.c \
                    jmi_cppad.cpp\
                    jmi_array_common.h \
                    jmi_array_cppad.h \
                    jmi_util.h \
                    jmi_util.c \
                    jmi_log.h \
                    jmi_log.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.c \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.h \
                    $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod_impl.h 
                   
libjmi_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g -I$(SUNDIALS_HOME)/include
libjmi_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g -I$(SUNDIALS_HOME)/include
libjmi_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g -I$(SUNDIALS_HOME)/include

libjmi_algorithm_cppad_la_SOURCES = jmi_init_opt.h \
                                    jmi_init_opt.c \
                                    jmi_opt_coll.h \
                                    jmi_opt_coll.c \
                                    jmi_opt_coll_radau.c
                   
libjmi_algorithm_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g -I$(SUNDIALS_HOME)/include
libjmi_algorithm_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_HOME) -DJMI_AD=JMI_AD_CPPAD -g -I$(SUNDIALS_HOME)/include
libjmi_algorithm_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g -I$(SUNDIALS_HOME)/include
#libjmi_cppad_la_LDFLAGS = -no-undefined 

libjmi_solver_cppad_la_SOURCES = jmi_opt_coll_ipopt.cpp \
                                 jmi_opt_coll_TNLP.cpp \
                                 jmi_init_opt_ipopt.cpp \
                                 jmi_init_opt_TNLP.cpp

libjmi_solver_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_HOME) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g -I$(SUNDIALS_HOME)/include
libjmi_solver_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_HOME) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD -g -I$(SUNDIALS_HOME)/include
libjmi_solver_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs -g -I$(SUNDIALS_HOME)/include
#libjmi_cppad_la_LDFLAGS = -no-undefined 

include_HEADERS = jmi.h \
                  fmiModelFunctions.h \
                  fmiModelTypes.h \
                  fmiCSFunctions.h \
                  fmiCSPlatformTypes.h \
                  fmi1_me.h \
                  fmi1_cs.h\
                  ModelicaUtilities.h \
                  jmi_common.h \
                  jmi_global.h \
                  jmi_simple_newton.h \
                  jmi_block_residual.h \
                  jmi_kinsol_solver.h \
                  jmi_linear_solver.h \
                  jmi_init_opt.h \
                  jmi_opt_coll.h \
                  jmi_opt_coll_radau.h \
                  jmi_array_common.h \
                  jmi_array_none.h \
                  jmi_array_cppad.h \
                  jmi_util.h \
                  jmi_log.h \
                  jmi_ode_solver.h \
                  jmi_ode_cvode.h \
                  jmi_ode_euler.h \
                  fmi1_functions.h \
                  fmi1_types.h \
                  $(abs_top_srcdir)/ThirdParty/MSL/Modelica/Resources/C-Sources/ModelicaTables.h \
                  $(abs_top_srcdir)/external/Assimulo/src/lib/kinpinv.h \
                  $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod.h \
                  $(abs_top_srcdir)/external/Assimulo/src/lib/kinsol_jmod_impl.h 

if COMPILE_WITH_IPOPT
include_HEADERS += jmi_opt_coll_ipopt.h
include_HEADERS += jmi_init_opt_ipopt.h
endif
