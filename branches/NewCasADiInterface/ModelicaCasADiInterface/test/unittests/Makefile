MCSRC=../../src
TYPES=$(MCSRC)/types/RealType.cpp $(MCSRC)/types/IntegerType.cpp $(MCSRC)/types/BooleanType.cpp $(MCSRC)/types/UserType.cpp $(MCSRC)/types/PrimitiveType.cpp $(MCSRC)/types/VariableType.cpp 
CPP=test.cpp
MODELICA_CASADI_PROGRAM = $(MCSRC)/Constraint.cpp $(MCSRC)/OptimizationProblem.cpp $(MCSRC)/Model.cpp $(MCSRC)/DerivativeVariable.cpp $(MCSRC)/RealVariable.cpp $(MCSRC)/IntegerVariable.cpp $(MCSRC)/BooleanVariable.cpp $(MCSRC)/Variable.cpp $(MCSRC)/Equation.cpp $(MCSRC)/ModelFunction.cpp $(TYPES)
LIBS=$(CASADI_HOME)/build/lib/libcasadi.so -ldl -lpthread
all: test

test: $(CPP)
	g++ -o test $(CPP) $(MODELICA_CASADI_PROGRAM)  $(LIBS) -I$(CASADI_HOME) -I$(BOOST_HOME) -I$(MCSRC) 

runtests: clean test
	LD_LIBRARY_PATH=$(CASADI_HOME)/build/lib ./test

runAndClean: runtests
	make clean

clean:
	rm -f test

.phony: all clean

