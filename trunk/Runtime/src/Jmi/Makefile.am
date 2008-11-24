AUTOMAKE_OPTIONS = foreign

lib_LTLIBRARIES = libjmi.la \
                  libjmi_cppad.la

libjmi_la_SOURCES = jmi.h \
                    jmi.c

libjmi_la_CFLAGS = -Wall -DJMI_AD=JMI_AD_NONE


#libjmi_la_LIBADD = $(JMALLLIBS)
#libjmi_la_DEPENDENCIES = $(JMALLLIBS)

#AM_CPPFLAGS = -I$(IPOPT_INC)

libjmi_cppad_la_SOURCES = jmi.h \
                    jmi_cppad.cpp

libjmi_cppad_la_CXXFLAGS = -Wall -I$(CPPAD_INC) -DJMI_AD=JMI_AD_CPPAD

include_HEADERS = jmi.h 
#		  jmi_cppad.hpp
