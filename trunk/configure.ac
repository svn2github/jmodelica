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
AC_INIT([jmodelica.org], 0.0.0, BUG-REPORT-ADDRESS)
AM_INIT_AUTOMAKE
AC_CONFIG_SRCDIR([JMI/src/jmi.h])
AC_CONFIG_HEADER([config.h])
AC_CONFIG_MACRO_DIR([m4])

# Checks for programs.
AC_PROG_CXX
AC_PROG_F77([gfortran])

# Acquire information about the platform
AC_CANONICAL_BUILD
AC_CANONICAL_HOST

# Different platforms use different standard name suffices for 
# shared libraries. Also the flag to gcc for creating a shared library
# differs. Also, on windows we need to make sure that we can build
# dll:s.
AC_SUBST(SHAREDEXT)
AC_SUBST(SHARED_LDFLAGS)
AC_SUBST(SEP)
SEP=':'
AC_SUBST(CURR_DIR)
CURR_DIR=`pwd`
case $build in
  *-cygwin*)
	echo "Cygwin detected"   
 	SHAREDEXT=".dll";
	SHARED_LDFLAGS=" -shared ";
	SEP='\;'
	AC_LIBTOOL_WIN32_DLL
	AC_DEFINE([WIN32],[1],[Building on a win32 system (detected Cygwin).])
    ;;
  *-mingw*)
	echo "MinGW detected"   
	SHAREDEXT=".dll";
	SHARED_LDFLAGS=" -shared ";
	SEP='\;'
	AC_LIBTOOL_WIN32_DLL
	AC_DEFINE([WIN32],[1],[Building on a win32 system (detected MinGW).])    
    ;;
  *-apple*)
	echo "Mac OS X detected"   
	AC_DEFINE([WIN32],[0],[Not a win32])    
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
	AC_DEFINE([WIN32],[0],[Not a win32])
	CFLAGS=" -fPIC $CFLAGS"
	CXXFLAGS=" -fPIC $CXXFLAGS"
    ;;  
esac
AC_PROG_LIBTOOL

# By default, we want to install bin, lib, and include
# in the directory where configure is run.

AC_PREFIX_DEFAULT(["/usr/local/jmodelica"])

#AS_IF([test "x$JMODELICA_HOME" = x],
# 	AC_PREFIX_DEFAULT([`pwd`]),
#        AC_PREFIX_DEFAULT(["$JMODELICA_HOME"]))

AS_IF([test "x$F77" != x],
      [AC_MSG_RESULT([gfortran seems to be working])],
      [AC_MSG_FAILURE([gfortran does not seem to be present or does not work properly])]) 

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

# Set output variables to be exported to the Makefiles
AC_SUBST(IPOPT_INC)
AC_SUBST(IPOPT_LIB)
AC_SUBST(IPOPT_HOME)

IPOPT_INC=$ipopt/include/coin
IPOPT_LIB=$ipopt/lib
IPOPT_HOME=$ipopt

AC_SUBST(WITH_CASADI)
AS_IF([test "x$with_casadi" != xno],
      [WITH_CASADI="true"],
      [WITH_CASADI="false"]) 

AC_ARG_WITH([casadi],
   [AS_HELP_STRING([--with-casadi],
     [CasADI Python-interface installation directory @<:@default=check@:>@])],
   [casadi=$withval],
   [with_casadi=no])

AS_IF([test "x$with_casadi" = xno],
      [AC_MSG_RESULT([CasADi installation not specified.])],
      [AC_CHECK_FILE($casadi/casadi/casadi.py,
                     [],
                     [AC_MSG_FAILURE([CasADi installation specifed, but seems to be corrupt!])])])

# Set output variables to be exported to the Makefiles
AC_SUBST(CASADI_HOME)

CASADI_HOME=$casadi

AC_SUBST(WITH_CASADI)
AS_IF([test "x$with_ipopt" != xno],
      [WITH_CASADI="true"],
      [WITH_CASADI="false"]) 


# Checks for libraries.
# SUNDIALS
AC_ARG_WITH([sundials],
   [AS_HELP_STRING([--with-sundials],
     [SUNDIALS installation directory @<:@default=check@:>@])],
   [sundials=$withval],
   [with_sundials=no])

AS_IF([test "x$with_sundials" = xno],
      [sundials="$CURR_DIR/sundials_install"])

AS_IF([test "x$with_sundials" = xno],
      [with_sundials=automatic])

# Set output variables to be exported to the Makefiles
AC_SUBST(SUNDIALS_HOME)
AC_SUBST(WITH_SUNDIALS)

AM_CONDITIONAL([WITH_SUNDIALS],[test "x$with_sundials" != xno])

AC_SUBST(SUNDIALS_HOME)
SUNDIALS_HOME=$sundials

AC_ARG_WITH([superlu],
  [AS_HELP_STRING([--with-superlu],
    [SuperLU installation directory @<:@default=check@:>@])],
  [superlu=$withval],
  [with_superlu=no])

AS_IF([test "x$with_superlu" = xno],
     [AC_MSG_RESULT([SuperLU installation not specified.])],
     [AC_MSG_RESULT([SuperLU installation specified.])])

AM_CONDITIONAL([WITH_SUPERLU],[test "x$with_superlu" != xno])

AC_SUBST(SUPERLU_HOME)
SUPERLU_HOME=$superlu

AC_ARG_WITH([eclipse],
   [AS_HELP_STRING([--with-eclipse],
     [Eclipse installation directory @<:@default=no@:>@])],
   [eclipse=$withval],
   [with_eclipse=no])

AS_IF([test "x$with_eclipse" = xno],
      [AC_MSG_RESULT([Eclipse installation not specified.])],
      [AC_CHECK_FILE($eclipse/eclipse,
                     [],
                     [AC_MSG_FAILURE([Eclipse installation specifed, but seems to be corrupt!])])])

AM_CONDITIONAL([WITH_ECLIPSE],[test "x$with_eclipse" != xno])

AC_SUBST(ECLIPSE_HOME)
ECLIPSE_HOME=$eclipse

# Checks for mingw.
AC_ARG_WITH([mingw],
   [AS_HELP_STRING([--with-mingw],
     [MinGW installation directory. @<:@default=no@:>@])],
   [mingw=$withval],
   [with_mingw=no])

AS_IF([test "x$with_mingw" = xno],
      [mingw=["$MINGW_HOME"]])

AS_IF([test "x$MINGW_HOME" != x],
      [with_mingw=env])

AS_IF([test "x$with_mingw" = xno],
      [AC_MSG_RESULT([MinGW installation not specified.])],
      [AC_CHECK_FILE($mingw/bin/gcc.exe,
                     [],
                     [AC_MSG_FAILURE([MinGW installation specifed, but seems to be corrupt!])])])

AM_CONDITIONAL([WITH_MINGW],[test "x$with_mingw" != xno])

# Set output variables to be exported to the Makefiles
AC_SUBST(MINGW_HOME)
MINGW_HOME=$mingw

# Detect Java home directory
AC_SUBST(_JAVA_HOME_)



case $build in
  *-mingw*)
    # The SDK installer sets the environment variable JAVA_HOME, so there we don't need _JAVA_HOME_
	_JAVA_HOME_=
    ;;
  *)
	_JAVA_HOME_=`$(dirname $0)/run_java.sh org.jmodelica.util.GetJavaHome`
    ;;  
esac


# Detect CppAD
AC_ARG_WITH([cppad],
   [AS_HELP_STRING([--with-cppad],
     [CppAD installation directory @<:@default=no@:>@])],
   [cppad=$withval],
   [with_cppad=no])

AS_IF([test "x$with_cppad" = xno],
      [cppad="ThirdParty/CppAD/cppad-20100325/"])

AS_IF([test "x$with_cppad" = xno],
      [AC_CHECK_FILE($srcdir/$cppad/cppad/cppad.hpp,
                     [],
                     [AC_MSG_FAILURE([CppAD sources not found - distribution corrupt?])])],
      [AC_CHECK_FILE($cppad/cppad/cppad.hpp,
                     [],
                     [AC_MSG_FAILURE([--with-cppad option was specified but does not seem to point at a valid CppAD installation])])])

AS_IF([test "x$with_cppad" = xno],
      [with_cppad=automatic])

AM_CONDITIONAL([COMPILE_WITH_CPPAD],[test "x$with_cppad" != xno])

# Set output variables to be exported to the Makefiles
AC_SUBST(CPPAD_HOME)
AC_SUBST(WITH_CPPAD)
AS_IF([test "x$with_cppad" = xautomatic],
      [CPPAD_HOME=`cd $srcdir; pwd`/$cppad],
      [CPPAD_HOME=$cppad])

AS_IF([test "x$with_cppad" != xno],
      [WITH_CPPAD="true"],
      [WITH_CPPAD="false"]) 

AC_SUBST(ipoptlib)
case $build in
  *-cygwin*)
    ipoptlib="-L$ipopt/lib -lipopt -lg2c -ldl"
    ;;
  *-mingw*)
    ipoptlib="-L$ipopt/lib -lipopt -lm \
       -lgfortran -lpthread -lmingw32 -lmoldname -lmingwex -lmsvcrt \
       -luser32 -lkernel32 -ladvapi32 -lshell32 -lstdc++"
    ;;
  *-apple*)
        ipoptlib="-L$ipopt/lib -lipopt -llapack -lblas -lm -lgfortran"
    ;;
  *)
    ipoptlib="-L$ipopt/lib -lipopt -llapack -lblas -lm -lgfortranbegin -lgfortran -lpthread"
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

AS_IF([test "x$ANT" = x],
      [AC_MSG_FAILURE([Cannot find Apache Ant - please install in order to build compiler front-ends.])])


# Checks for header files.
AC_HEADER_STDC
AC_CHECK_HEADERS([stdlib.h])

# Checks for typedefs, structures, and compiler characteristics.
AC_HEADER_STDBOOL
AC_C_CONST

AC_CONFIG_SUBDIRS([ThirdParty/Sundials/sundials-2.5.0])

AC_CONFIG_FILES([
 Makefile
 ThirdParty/Blas/Makefile
 ThirdParty/Lapack/Makefile
 ThirdParty/Sundials/Makefile
 ThirdParty/CasADi/Makefile
 external/FMILibrary/Makefile
 JMI/src/Makefile
 JMI/Makefile
 docbook/UsersGuide/Makefile
 Python/jm_ipython.sh
 Python/jm_python.sh
 RuntimeLibrary/Makefile
 jm_tests
])

AC_OUTPUT

AC_MSG_RESULT([Configure completed successfully!])
