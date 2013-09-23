# JCC
JCC=../../../jcc
JCC_SRC=$(JCC)/initjcc.cpp $(JCC)/jccutils.cpp $(JCC)/JCCEnv.cpp $(JCC)/JObject.cpp
# JModelica install interfaced with CasADi
JM_CASADI_BACKEND=../../../../JModelicaCasADiBackend/trunk
JMODELICA=$(JM_CASADI_BACKEND)/JModelica.org
OPT_COMPILER=$(JMODELICA)/Compiler/OptimicaCompiler
# JAR-files
OPT_COMPILER_JAR_DIR=$(OPT_COMPILER)/bin
BEAVER_JAR=$(JMODELICA)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver.jar
JARS=$(OPT_COMPILER_JAR_DIR)/OptimicaCompiler.jar:$(OPT_COMPILER_JAR_DIR)/util.jar:$(BEAVER_JAR)
# The ModelicaCasADi program
MCSRC=../../src
TYPES=$(MCSRC)/types/RealType.cpp $(MCSRC)/types/IntegerType.cpp $(MCSRC)/types/BooleanType.cpp $(MCSRC)/types/UserType.cpp $(MCSRC)/types/PrimitiveType.cpp $(MCSRC)/types/VariableType.cpp 
MODELICA_CASADI_PROGRAM =$(MCSRC)/Model.cpp  $(MCSRC)/Equation.cpp $(MCSRC)/DerivativeVariable.cpp $(MCSRC)/RealVariable.cpp $(MCSRC)/IntegerVariable.cpp $(MCSRC)/BooleanVariable.cpp $(MCSRC)/Variable.cpp $(MCSRC)/ModelFunction.cpp  $(MCSRC)/Constraint.cpp $(MCSRC)/OptimizationProblem.cpp $(MCSRC)/transferOptimica.cpp $(TYPES)
# Flags compiling the executable, including libraries that CasADi needs.
OPT_FLAGS= $(MODELICA_CASADI_PROGRAM) -lcasadi_ipopt_interface -lcasadi_optimal_control -lcasadi_tinyxml -lcasadi_csparse_interface -lcasadi  -lipopt -llapack -ldl -lcoinmumps -lblas -lpthread -lgfortran -lm -lgcc_s -lquadmath -lcoinmetis -lcoinhsl
EXE_OPT_CFLAGS=-ldl -lpthread  
CFLAGS=-I$(JAVA_HOME)/include
LIBCASADI=$(CASADI_HOME)/build/lib/libcasadi.so
# Name of executable
PROGRAM_EXECUTABLE=optimicaTransfer


all: runtests
				  
buildOpt/:
	rm -rf build
	python -m jcc --classpath $(JARS):. \
		  java.lang.System \
		  java.lang.Object \
		  java.util.ArrayList \
		  java.util.Set \
		  java.util.Iterator \
		  java.io.PrintStream \
		  casadi.MX \
		  casadi.MXFunction \
		  casadi.MXVector \
		  org.jmodelica.util.OptionRegistry \
		  org.jmodelica.optimica.compiler.OptimicaCompiler \
		  org.jmodelica.optimica.compiler.FDerivedType \
		  org.jmodelica.optimica.compiler.FType \
		  org.jmodelica.optimica.compiler.FStringComment \
		  org.jmodelica.optimica.compiler.FAttribute \
		  org.jmodelica.optimica.compiler.SourceRoot \
		  org.jmodelica.optimica.compiler.InstClassDecl \
		  org.jmodelica.optimica.compiler.FClass \
		  org.jmodelica.optimica.compiler.FOptClass \
		  org.jmodelica.optimica.compiler.FConstraint \
		  org.jmodelica.optimica.compiler.FRelationConstraint \
		  org.jmodelica.optimica.compiler.FConstraintEq \
		  org.jmodelica.optimica.compiler.FConstraintLeq \
		  org.jmodelica.optimica.compiler.FConstraintGeq \
		  org.jmodelica.optimica.compiler.List \
		  org.jmodelica.optimica.compiler.FEquationBlock \
		  org.jmodelica.optimica.compiler.FAbstractEquation \
		  org.jmodelica.optimica.compiler.FEquation \
		  org.jmodelica.optimica.compiler.FFunctionCallEquation \
		  org.jmodelica.optimica.compiler.FFunctionCallLeft \
		  org.jmodelica.optimica.compiler.FExp \
		  org.jmodelica.optimica.compiler.FIdUse \
		  org.jmodelica.optimica.compiler.FIdUseExp \
		  org.jmodelica.optimica.compiler.FVariable \
		  org.jmodelica.optimica.compiler.FRealVariable \
		  org.jmodelica.optimica.compiler.FDerivativeVariable \
		  org.jmodelica.optimica.compiler.FFunctionCall \
		  org.jmodelica.optimica.compiler.FVectorFunctionCall \
		  org.jmodelica.optimica.compiler.FFunctionDecl \
		  org.jmodelica.optimica.compiler.FAssignStmt \
		  org.jmodelica.optimica.compiler.FFunctionCallStmt \
		  org.jmodelica.optimica.compiler.FFunctionVariable \
		  org.jmodelica.optimica.compiler.FAlgorithm 

$(PROGRAM_EXECUTABLE): 
	g++ -o $(PROGRAM_EXECUTABLE) trajCreator.cpp  build/__wrap__.cpp \
		$(JCC_SRC) \
		$(LIBCASADI) \
		-L$(CASADI_HOME)/build/lib \
		-Ibuild \
		-I$(JCC) \
		-I$(CASADI_HOME) \
		-I$(BOOST_HOME) \
		-I$(MCSRC) \
		$(EXE_OPT_CFLAGS) $(OPT_FLAGS) $(CFLAGS)

optimizer: clean buildOpt $(PROGRAM_EXECUTABLE) 
	rm -f make_mc_traj.sh
	echo "#!/bin/sh" > make_mc_traj.sh
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(JM_CASADI_BACKEND)/lib\" ./$(PROGRAM_EXECUTABLE) $(JARS)" >> make_mc_traj.sh
	chmod u+x make_mc_traj.sh

clean:
	rm -rf build
	rm -f vdp*
	rm -f opt*One*
	rm -f *.pyc
	rm -f mc_transfer*.txt
	rm -f make_mc_traj.sh
	rm -rf build
	rm -rf runTests.sh
	rm -f $(PROGRAM_EXECUTABLE)

runtests: optimizer
	echo "#!/bin/sh" > runTests.sh
	echo "./make_mc_traj.sh" >> runTests.sh
	echo "JMODELICA_HOME=/home/bjorn/JModelicaInstall \\" >> runTests.sh
	echo "IPOPT_HOME=/usr/local \\" >> runTests.sh
	echo "CPPAD_HOME=/home/bjorn/JModelicaInstall/ThirdParty/CppAD/ \\" >> runTests.sh
	echo "SUNDIALS_HOME=/home/bjorn/JModelicaInstall/ThirdParty/Sundials \\" >> runTests.sh
	echo "PYTHONPATH=:/home/bjorn/JModelicaInstall/Python/: \\" >> runTests.sh
	echo "LD_LIBRARY_PATH=:/usr/local/lib/:/home/bjorn/JModelicaInstall/ThirdParty/Sundials/lib \\" >> runTests.sh
	echo "SEPARATE_PROCESS_JVM=/usr/lib/jvm/java-6-openjdk-amd64/ \\" >> runTests.sh
	echo "nosetests" >> runTests.sh
	chmod u+x runTests.sh
	./runTests.sh

runAndClean: runtests
	make clean

.PHONY: all clean
