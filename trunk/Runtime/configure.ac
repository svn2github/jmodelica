#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([JModelicaRT], 0.0.1, BUG-REPORT-ADDRESS)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/Jmi/jmi_dae.h])
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
#AC_ARG_WITH([ipopt],
#   [AS_HELP_STRING([--with-ipopt],
#     [ipopt installation directory @<:@default=check@:>@])],
#   [ipopt=$withval],
#   [with_ipopt=no])

#AS_IF([test "x$with_ipopt" = xno],
#      [AC_MSG_FAILURE([--with-ipopt option must be specified])],
#      [AC_CHECK_FILE($ipopt/include/coin/IpTNLP.hpp,
#                     [],
#                     [AC_MSG_FAILURE([--with-ipopt option was specified but does not seem to point at a valid Ipopt installation])])])

# Set output variables to be exported to the Makefiles
AC_SUBST(IPOPT_INC)
AC_SUBST(IPOPT_LIB)

IPOPT_INC=$ipopt/include/coin
IPOPT_LIB=$ipopt/lib

# Set LDFLAGS AND LIBS
AC_SUBST(APP_LDFLAGS)
AC_SUBST(APP_LIBS)
APP_LDFLAGS=-L$ipopt/lib
case $build in
  *-cygwin*)
    APP_LIBS="-lipopt -lg2c -ldl"
    ;;
  *-mingw*)
    APP_LIBS="-lipopt -lg2c"
    ;;
  *)
    APP_LIBS="-lipopt -llapack -lblas -lm -lgfortranbegin -lgfortran"
    ;;  
esac

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
 src/Jmi/Makefile
 src/Jmi3/Makefile
 src/examples/Vdp/Makefile
 src/examples/Vdp3/Makefile
])



AC_OUTPUT
