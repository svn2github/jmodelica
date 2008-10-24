#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([JModelicaRT], 0.0.1, BUG-REPORT-ADDRESS)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/IpoptInterface/OptimicaTNLP.cpp])
AC_CONFIG_HEADER([config.h])

# Checks for programs.
AC_PROG_CXX

# Libraries will be built
#AC_PROG_RANLIB
AC_PROG_LIBTOOL

# By default, we want to install bin, lib, and include
# in the directory where configure is run.
AC_PREFIX_DEFAULT([`pwd`])

# Checks for libraries.

# Set output variables to be exported to the Makefiles
AC_SUBST(IPOPT_INC)
AC_SUBST(IPOPT_LIB)

IPOPT_INC="/work/jakesson/software_tools/Ipopt/Ipopt-3.5.4/build/include/coin"
IPOPT_LIB="/work/jakesson/software_tools/Ipopt/Ipopt-3.5.4/build/lib"

AC_SUBST(JMALLLIBS)
JMALLLIBS="../ModelInterface/libmodelinterface.la ../OptimicaInterface/liboptimica.la"

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST

# Checks for library functions.

AC_CONFIG_FILES([
 Makefile
 src/ModelInterface/Makefile
 src/OptimicaInterface/Makefile
 src/IpoptInterface/Makefile
 src/examples/VDPExample/Makefile
])



AC_OUTPUT
