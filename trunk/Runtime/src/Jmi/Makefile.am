AUTOMAKE_OPTIONS = foreign

lib_LTLIBRARIES = libjmi.la
libjmi_la_SOURCES = jmi.h \
                    jmi.c
#                    jmi_cppad.hpp \
#                    jmi_cppad.cpp

libjmi_la_CFLAGS = -Wall -I$(CPPAD_INC)
libjmi_la_CXXFLAGS = -Wall -I$(CPPAD_INC)

#libjmi_la_LIBADD = $(JMALLLIBS)
#libjmi_la_DEPENDENCIES = $(JMALLLIBS)

#AM_CPPFLAGS = -I$(IPOPT_INC)

include_HEADERS = jmi.h 
#		  jmi_cppad.hpp
