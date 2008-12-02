#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([JModelicaRT], 0.0.1, BUG-REPORT-ADDRESS)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([src/jmi/jmi.h])
AC_CONFIG_HEADER([config.h])

# Checks for programs.
AC_PROG_CXX

# Acquire information about the platform
AC_CANONICAL_BUILD
AC_CANONICAL_HOST

# Different platforms use different standard name suffices for 
# shared libraries. Also the flag to gcc for creating a shared library
# differs. Also, on windows we need to make sure that we can build
# dll:s.
AC_SUBST(SHAREDEXT)
AC_SUBST(SHARED_LDFLAGS)
case $build in
  *-cygwin*)
	echo "Cygwin detected"   
 	SHAREDEXT=".dll";
    	SHARED_LDFLAGS=" -shared ";
    	AC_LIBTOOL_WIN32_DLL
    	AC_DEFINE([WIN32],[1],[Building on a win32 system (detected Cygwin).])
    ;;
  *-mingw*)
	echo "MinGW detected"   
    	SHAREDEXT=".dll";
    	SHARED_LDFLAGS=" -shared ";
    	AC_LIBTOOL_WIN32_DLL
    	AC_DEFINE([WIN32],[1],[Building on a win32 system (detected MinGW).])    
    ;;
  *-apple*)
	echo "Mac OS X detected"   
    	SHAREDEXT=".dylib";
    	SHARED_LDFLAGS=" -dynamiclib ";
    ;;
  *)
	echo "Linux detected"   
    	APP_LIBS="-lipopt -llapack -lblas -lm -lgfortranbegin -lgfortran"
    	SHAREDEXT=".so";
   	SHARED_LDFLAGS=" -shared ";
	# The fPIC flag is used to make the code independent of position in the
	# memory. This is needed on Linux x86_64 platforms.
	CFLAGS=" -fPIC $CFLAGS"
	CXXFLAGS=" -fPIC $CXXFLAGS"
    ;;  
esac
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

AC_ARG_WITH([cppad],
   [AS_HELP_STRING([--with-cppad],
     [CppAD installation directory @<:@default=check@:>@])],
   [cppad=$withval],
   [with_cppad=no])

AS_IF([test "x$with_cppad" = xno],
      [AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --with-cppad option not specified - compiling without CppAD support *])
       AC_MSG_RESULT([***********************************************************************])],
       [AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --with-cppad option specified - compiling with CppAD support        *])
       AC_MSG_RESULT([***********************************************************************])
       AC_CHECK_FILE($cppad/cppad/cppad.hpp,
                     [],
                     [AC_MSG_FAILURE([--with-cppad option was specified but does not seem to point at a valid CppAD installation])])])

# Set output variables to be exported to the Makefiles
AC_SUBST(CPPAD_INC)

CPPAD_INC=$cppad

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

#AC_SUBST(JMALLLIBS)
#JMALLLIBS="../ModelInterface/libmodelinterface.la ../OptimicaInterface/liboptimica.la"

# Used in examples
jmilib="-L\$(JMILIBDIR) -ljmi";
AC_SUBST(jmilib)

jmi_cppadlib="-L\$(JMILIBDIR) -ljmi_cppad";
AC_SUBST(jmi_cppadlib)

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST

# Checks for library functions.

AC_CONFIG_FILES([
 Makefile
 src/jmi/Makefile
 examples/Vdp/Makefile
 examples/Vdp_cppad/Makefile
])



AC_OUTPUT
