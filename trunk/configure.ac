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


#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ(2.61)
AC_INIT([JModelica], 0.0.1, BUG-REPORT-ADDRESS)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([JMI/src/jmi.h])
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
AC_ARG_WITH([ipopt],
   [AS_HELP_STRING([--with-ipopt],
     [IPOPT installation directory @<:@default=check@:>@])],
   [ipopt=$withval],
   [with_ipopt=no])

AS_IF([test "x$with_ipopt" = xno],
      [AC_MSG_RESULT([ ])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --with-ipopt option not specified - compiling without IPOPT support *])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([ ])],
       [AC_MSG_RESULT([ ])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --with-ipopt option specified - compiling with IPOPT support        *])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([ ])
       AC_CHECK_FILE($ipopt/include/coin/IpStdCInterface.h,
                     [],
                     [AC_MSG_FAILURE([--with-ipopt option was specified but does not seem to point at a valid IPOPT installation])])])

AM_CONDITIONAL([COMPILE_WITH_IPOPT],[test "x$with_ipopt" != xno])



#AS_IF([test "x$with_ipopt" = xno],
#      [AC_MSG_FAILURE([--with-ipopt not specified])],
#       [AC_MSG_RESULT([ ])
#       AC_MSG_RESULT([***********************************************************************])
#       AC_MSG_RESULT([* --with-ipopt option specified - compiling with IPOPT support        *])
#       AC_MSG_RESULT([***********************************************************************])
#       AC_MSG_RESULT([ ])
#       AC_CHECK_FILE($ipopt/include/coin/IpStdCInterface.h,
#                     [],
#                     [AC_MSG_FAILURE([--with-ipopt option was specified but does not seem to point at a valid IPOPT installation])])])

# Set output variables to be exported to the Makefiles
AC_SUBST(IPOPT_INC)
AC_SUBST(IPOPT_LIB)
AC_SUBST(IPOPT_HOME)

IPOPT_INC=$ipopt/include/coin
IPOPT_LIB=$ipopt/lib
IPOPT_HOME=$ipopt

AC_SUBST(WITH_IPOPT)
AS_IF([test "x$with_ipopt" != xno],
      [WITH_IPOPT="true"],
      [WITH_IPOPT="false"]) 

AC_ARG_WITH([cppad],
   [AS_HELP_STRING([--with-cppad],
     [CppAD installation directory @<:@default=check@:>@])],
   [cppad=$withval],
   [with_cppad=no])

AS_IF([test "x$with_cppad" = xno],
      [AC_MSG_RESULT([ ])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --with-cppad option not specified - compiling without CppAD support *])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([ ])],
       [AC_MSG_RESULT([ ])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([* --with-cppad option specified - compiling with CppAD support        *])
       AC_MSG_RESULT([***********************************************************************])
       AC_MSG_RESULT([ ])
       AC_CHECK_FILE($cppad/cppad/cppad.hpp,
                     [],
                     [AC_MSG_FAILURE([--with-cppad option was specified but does not seem to point at a valid CppAD installation])])])

AM_CONDITIONAL([COMPILE_WITH_CPPAD],[test "x$with_cppad" != xno])

# Set output variables to be exported to the Makefiles
AC_SUBST(CPPAD_INC)
AC_SUBST(WITH_CPPAD)
CPPAD_INC=$cppad

AS_IF([test "x$with_cppad" != xno],
      [WITH_CPPAD="true"],
      [WITH_CPPAD="false"]) 

AC_SUBST(ipoptlib)
case $build in
  *-cygwin*)
    ipoptlib="-L$ipopt/lib -lipopt -lg2c -ldl"
    ;;
  *-mingw*)
    ipoptlib="-L$ipopt/lib -lipopt -lm -lfrtbegin \
       -lg2c -lmingw32 -lmoldname -lmingwex -lmsvcrt \
       -luser32 -lkernel32 -ladvapi32 -lshell32 -lstdc++"
    ;;
  *-apple*)
        ipoptlib="-L$ipopt/lib -lipopt -llapack -lblas -lm -lgfortran"
    ;;
  *)
    ipoptlib="-L$ipopt/lib -lipopt -llapack -lblas -lm -lgfortranbegin -lgfortran"
    ;;  
esac

#AC_SUBST(JMALLLIBS)
#JMALLLIBS="../ModelInterface/libmodelinterface.la ../OptimicaInterface/liboptimica.la"

# Used in examples
#jmilib="-L\$(JMILIBDIR) -ljmi -ljmi_algorithm";
AS_IF([test "x$with_ipopt" != xno],
      [jmilib="-L\$(JMILIBDIR) -ljmi -ljmi_algorithm -ljmi_solver"], 
      [jmilib="-L\$(JMILIBDIR) -ljmi -ljmi_algorithm"])  
AC_SUBST(jmilib)

#jmi_cppadlib="-L\$(JMILIBDIR) -ljmi_cppad -ljmi_algorithm_cppad";
AS_IF([test "x$with_ipopt" != xno],
      [jmi_cppadlib="-L\$(JMILIBDIR) -ljmi_cppad -ljmi_algorithm_cppad -ljmi_solver_cppad"], 
      [jmi_cppadlib="-L\$(JMILIBDIR) -ljmi_cppad -ljmi_algorithm_cppad"])  
AC_SUBST(jmi_cppadlib)

AC_PATH_PROG([ANT], [ant], [])
AC_SUBST(ANT_OPTS)
ANT_OPTS="ANT_OPTS=-Xmx1024M"

AM_CONDITIONAL([HAVE_ANT],[test "x$ANT" != x])

# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST

# Checks for library functions.

AC_CONFIG_FILES([
 Makefile
 JMI/src/Makefile
 JMI/examples/Vdp/Makefile
 JMI/examples/Vdp_cppad/Makefile
 JMI/examples/FurutaPendulum/Makefile
 JMI/examples/CSTR/Makefile
 JMI/examples/CSTR2/Makefile
 Options/options_tpl.xml
 Options/options_tpl.py
])


AC_OUTPUT

AC_MSG_RESULT([Configure completed successfully!])