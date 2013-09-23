SEP=:
# JCC
JCC=../../../jcc
JCC_SRC=$(JCC)/initjcc.cpp $(JCC)/jccutils.cpp $(JCC)/JCCEnv.cpp $(JCC)/JObject.cpp
# JModelica install interfaced with CasADi
JM_CASADI_BACKEND=../../../../JModelicaCasADiBackend/trunk
JMODELICA=$(JM_CASADI_BACKEND)/JModelica.org
OPT_COMPILER=$(JMODELICA)/Compiler/OptimicaCompiler
MODELICA_COMPILER=$(JMODELICA)/Compiler/ModelicaCompiler
# JAR-files
MODELICA_COMPILER_JAR_DIR=$(MODELICA_COMPILER)/bin
OPT_COMPILER_JAR_DIR=$(OPT_COMPILER)/bin
BEAVER_JAR=$(JMODELICA)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver.jar
JARS_MOD=$(MODELICA_COMPILER_JAR_DIR)/ModelicaCompiler.jar$(SEP)$(MODELICA_COMPILER_JAR_DIR)/util.jar$(SEP)$(BEAVER_JAR)
JARS_OPT=$(OPT_COMPILER_JAR_DIR)/OptimicaCompiler.jar:$(OPT_COMPILER_JAR_DIR)/util.jar:$(BEAVER_JAR)
# The ModelicaCasADi program
MCSRC=../../src
TYPES=$(MCSRC)/types/RealType.cpp $(MCSRC)/types/IntegerType.cpp $(MCSRC)/types/BooleanType.cpp $(MCSRC)/types/UserType.cpp $(MCSRC)/types/PrimitiveType.cpp $(MCSRC)/types/VariableType.cpp 
MODELICA_CASADI_PROGRAM = $(MCSRC)/Model.cpp  $(MCSRC)/Equation.cpp $(MCSRC)/DerivativeVariable.cpp $(MCSRC)/RealVariable.cpp $(MCSRC)/IntegerVariable.cpp  $(MCSRC)/BooleanVariable.cpp  $(MCSRC)/Variable.cpp $(MCSRC)/ModelFunction.cpp $(TYPES)
MODELICA_CASADI_OPTIMICA = $(MODELICA_CASADI_PROGRAM) $(MCSRC)/Constraint.cpp $(MCSRC)/OptimizationProblem.cpp
# Flags compiling the executable, including libraries that CasADi needs.
OPT_FLAGS= $(MODELICA_CASADI_OPTIMICA) $(MCSRC)/transferOptimica.cpp -lcasadi_ipopt_interface -lcasadi_optimal_control -lcasadi_tinyxml -lcasadi_csparse_interface -lcasadi  -lipopt -llapack -ldl -lcoinmumps -lblas -lpthread -lgfortran -lm -lgcc_s -lquadmath -lcoinmetis -lcoinhsl
MOD_FLAGS= $(MODELICA_CASADI_PROGRAM) $(MCSRC)/transferModelica.cpp -lcasadi
EXE_CFLAGS=-ldl -lpthread  
CFLAGS=-I$(JAVA_HOME)/include
LIBCASADI=$(CASADI_HOME)/build/lib/libcasadi.so
# Name of executable
PROGRAM_OPT_EXECUTABLE=transferOptimica
PROGRAM_MOD_EXECUTABLE=transferModelica
CONSTRUCT_TESTS_EXECUTABLE=testConstructCreation


all: runAndClean

buildOpt/:
	rm -rf build
	python -m jcc --classpath $(JARS_OPT):. \
		  java.lang.System \
		  java.lang.Object \
		  java.util.ArrayList \
		  casadi.MX \
		  casadi.MXFunction \
		  casadi.MXVector \
		  org.jmodelica.util.OptionRegistry \
		  org.jmodelica.optimica.compiler.OptimicaCompiler \
		  org.jmodelica.optimica.compiler.FStringComment \
		  org.jmodelica.optimica.compiler.FAttribute \
		  org.jmodelica.optimica.compiler.FDerivedType \
		  org.jmodelica.optimica.compiler.FType \
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
		  org.jmodelica.optimica.compiler.FIfStmt \
		  org.jmodelica.optimica.compiler.FFunctionCallStmt \
		  org.jmodelica.optimica.compiler.FFunctionVariable \
		  org.jmodelica.optimica.compiler.FAlgorithm 


# Invoke JCC. List all Java classes that you need to wrap here:
buildMod/:
	rm -rf build
	python -m jcc --classpath $(JARS_MOD):. \
		  java.lang.System \
		  java.util.ArrayList \
		  casadi.MX \
		  casadi.MXFunction \
		  casadi.MXVector \
		  org.jmodelica.util.OptionRegistry \
		  org.jmodelica.modelica.compiler.ModelicaCompiler \
		  org.jmodelica.modelica.compiler.FDerivedType \
		  org.jmodelica.modelica.compiler.FType \
		  org.jmodelica.modelica.compiler.FAttribute \
		  org.jmodelica.modelica.compiler.FStringComment \
		  org.jmodelica.modelica.compiler.SourceRoot \
		  org.jmodelica.modelica.compiler.InstClassDecl \
		  org.jmodelica.modelica.compiler.FClass \
		  org.jmodelica.modelica.compiler.List \
		  org.jmodelica.modelica.compiler.FEquationBlock \
		  org.jmodelica.modelica.compiler.FAbstractEquation \
		  org.jmodelica.modelica.compiler.FEquation \
		  org.jmodelica.modelica.compiler.FFunctionCallEquation \
		  org.jmodelica.modelica.compiler.FFunctionCallLeft \
		  org.jmodelica.modelica.compiler.FExp \
		  org.jmodelica.modelica.compiler.FIdUse \
		  org.jmodelica.modelica.compiler.FIdUseExp \
		  org.jmodelica.modelica.compiler.FVariable \
		  org.jmodelica.modelica.compiler.FRealVariable \
		  org.jmodelica.modelica.compiler.FDerivativeVariable \
		  org.jmodelica.modelica.compiler.FFunctionCall \
		  org.jmodelica.modelica.compiler.FFunctionDecl \
		  org.jmodelica.modelica.compiler.FAssignStmt \
		  org.jmodelica.modelica.compiler.FFunctionCallStmt \
		  org.jmodelica.modelica.compiler.FFunctionVariable \
		  org.jmodelica.modelica.compiler.FAlgorithm 
				  

$(CONSTRUCT_TESTS_EXECUTABLE):
	g++ -o $(CONSTRUCT_TESTS_EXECUTABLE) testJMConstructExposedToCasADi.cpp build/__wrap__.cpp \
		$(JCC_SRC) \
		$(LIBCASADI) \
		-L$(CASADI_HOME)/build/lib \
		-Ibuild \
		-I$(JCC) \
		-I$(CASADI_HOME) \
		$(EXE_CFLAGS) -lcasadi $(CFLAGS)

$(PROGRAM_OPT_EXECUTABLE): 
	g++ -o $(PROGRAM_OPT_EXECUTABLE) testOptimicaTransfer.cpp  build/__wrap__.cpp \
		$(JCC_SRC) \
		$(LIBCASADI) \
		-L$(CASADI_HOME)/build/lib \
		-Ibuild \
		-I$(JCC) \
		-I$(CASADI_HOME) \
		-I$(BOOST_HOME) \
		-I$(MCSRC) \
		$(EXE_CFLAGS) $(OPT_FLAGS) $(CFLAGS)


$(PROGRAM_MOD_EXECUTABLE): 
	g++ -o $(PROGRAM_MOD_EXECUTABLE) testModelicaTransfer.cpp build/__wrap__.cpp \
		$(JCC_SRC) \
		$(LIBCASADI) \
		-L$(CASADI_HOME)/build/lib \
		-Ibuild \
		-I$(JCC) \
		-I$(CASADI_HOME) \
		-I$(BOOST_HOME) \
		-I$(MCSRC) \
		$(EXE_CFLAGS) $(MOD_FLAGS) $(CFLAGS)

constructTests: buildMod $(CONSTRUCT_TESTS_EXECUTABLE)
	echo "#!/bin/sh" > runConstructTests.sh
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(JM_CASADI_BACKEND)/lib\" ./$(CONSTRUCT_TESTS_EXECUTABLE) $(JARS_MOD)" >> runConstructTests.sh
	chmod u+x runConstructTests.sh

modelica:  buildMod $(PROGRAM_MOD_EXECUTABLE)
	echo "#!/bin/sh" > runMod.sh
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(JM_CASADI_BACKEND)/lib\" ./$(PROGRAM_MOD_EXECUTABLE) $(JARS_MOD)" >> runMod.sh
	chmod u+x runMod.sh

optimizer: buildOpt $(PROGRAM_OPT_EXECUTABLE) 
	rm -f runOpt.sh
	echo "#!/bin/sh" > runOpt.sh
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(JM_CASADI_BACKEND)/lib\" ./$(PROGRAM_OPT_EXECUTABLE) $(JARS_OPT)" >> runOpt.sh
	chmod u+x runOpt.sh

clean:
	rm -rf build
	rm -f $(PROGRAM_MOD_EXECUTABLE) runMod.sh
	rm -f $(PROGRAM_OPT_EXECUTABLE) runOpt.sh
	rm -f $(CONSTRUCT_TESTS_EXECUTABLE) runConstructTests.sh
	rm -f hs_err_pid*

tests: modelica constructTests optimizer

runAndClean: clean tests
	./runMod.sh
	./runOpt.sh
	./runConstructTests.sh
	make clean

.PHONY: all clean
