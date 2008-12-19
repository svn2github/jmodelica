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

libjmi_la_CFLAGS = -Wall -I$(IPOPT_INC) -DJMI_AD=JMI_AD_NONE 
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
                    jmi_opt_sim_lp.c
                   
libjmi_cppad_la_CFLAGS = -Wall -x c++ -I$(CPPAD_INC) -I$(IPOPT_INC) -DJMI_AD=JMI_AD_CPPAD 
libjmi_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD 
libjmi_cppad_la_LDFLAGS = -no-undefined -static-libtool-libs 
#libjmi_cppad_la_LDFLAGS = -no-undefined 

include_HEADERS = jmi.h \
                  jmi_common.h \
                  jmi_opt_sim.h \
                  jmi_opt_sim_ipopt.h

