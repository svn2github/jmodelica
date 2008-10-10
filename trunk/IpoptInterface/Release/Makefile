# Copyright (C) 2003, 2006 International Business Machines and others.
# All Rights Reserved.
# This file is distributed under the Common Public License.

# $Id: Makefile.in 1135 2007-12-27 19:23:06Z andreasw $

##########################################################################
#    You can modify this example makefile to fit for your own program.   #
#    Usually, you only need to change the five CHANGEME entries below.   #
##########################################################################

# CHANGEME: This should be the name of your executable
EXE = IpoptExample

# CHANGEME: Here is the name of all object files corresponding to the source
#           code that you wrote in order to define the problem statement
OBJS =  ./examples/SimpleExample/SimpleExample.o \
	./OptimicaInterface/SimultaneousInterface.o \
	./ModelInterface/ModelInterface.o \
	./IpoptInterface/OptimicaTNLP.o

# CHANGEME: Additional libraries
ADDLIBS =

# CHANGEME: Additional flags for compilation (e.g., include flags)
ADDINCFLAGS =

# CHANGEME: Directory to the sources for the (example) problem definition
# files
SRCDIR = ../src/
VPATH = ../src/

##########################################################################
#  Usually, you don't have to change anything below.  Note that if you   #
#  change certain compiler options, you might have to recompile Ipopt.   #
##########################################################################

# C++ Compiler command
CXX = g++

# C++ Compiler options
CXXFLAGS = -O3 -fomit-frame-pointer -pipe -DNDEBUG -pedantic-errors -Wimplicit -Wparentheses -Wreturn-type -Wcast-qual -Wall -Wpointer-arith -Wwrite-strings -Wconversion -Wno-unknown-pragmas  

# additional C++ Compiler options for linking
CXXLINKFLAGS =  -Wl,--rpath -Wl,/home/claird/workspace/Ipopt/opt/lib

# Directory with header files
IPOPTINCDIR = ${prefix}/include/coin

# Directory with libipopt.a
IPOPTLIBDIR = ${exec_prefix}/lib
exec_prefix = ${prefix}
prefix = /home/claird/workspace/Ipopt/opt

# Libraries necessary to link with IPOPT
#LIBS = -L$(IPOPTLIBDIR) -lipopt @IPADDLIBS@
LIBS = -L$(IPOPTLIBDIR) -lipopt -lm  -ldl  -L/usr/lib/gcc/x86_64-linux-gnu/4.2.3 -L/usr/lib/gcc/x86_64-linux-gnu/4.2.3/../../../../lib -L/lib/../lib -L/usr/lib/../lib -L/usr/lib/gcc/x86_64-linux-gnu/4.2.3/../../.. -lgfortranbegin -lgfortran -lm -lgcc_s

# Necessary Include dirs (we use the CYGPATH_W variables to allow
# compilation with Windows compilers)
INCL =  -I`$(CYGPATH_W) $(IPOPTINCDIR)` $(ADDINCFLAGS)

# The following is necessary under cygwin, if native compilers are used
CYGPATH_W = echo

all: $(EXE)

.SUFFIXES: .cpp .c .o .obj

$(EXE): $(OBJS)
	bla=;\
	for file in $(OBJS); do bla="$$bla `$(CYGPATH_W) $$file`"; done; \
	$(CXX) $(CXXLINKFLAGS) $(CXXFLAGS) -o $@ $$bla $(ADDLIBS) $(LIBS)

clean:
	rm -rf $(EXE) $(OBJS)

.cpp.o:
	$(CXX) $(CXXFLAGS) $(INCL) -c -o $@ `test -f '$<' || echo '$(SRCDIR)/'`$<


.cpp.obj:
	$(CXX) $(CXXFLAGS) $(INCL) -c -o $@ `if test -f '$<'; then $(CYGPATH_W) '$<'; else $(CYGPATH_W) '$(SRCDIR)/$<'; fi`
