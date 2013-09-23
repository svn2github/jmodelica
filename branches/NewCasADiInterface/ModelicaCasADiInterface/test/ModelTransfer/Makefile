# Search paths to external dependencies: trunk/jcc and JModelicaCasADiBackend/trunk
JCC=../../../jcc
MCB=../../../../JModelicaCasADiBackend/trunk

JCC_SRC=$(JCC)/initjcc.cpp $(JCC)/jccutils.cpp $(JCC)/JCCEnv.cpp $(JCC)/JObject.cpp
JCC_H=$(JCC)/initjcc.h $(JCC)/jccutils.h $(JCC)/sxwrap.hpp $(JCC)/mxwrap.hpp $(JCC)/JArray.h $(JCC)/JCCEnv.h $(JCC)/JObject.h

JMODELICA=$(MCB)/JModelica.org
MC=$(JMODELICA)/Compiler/ModelicaCompiler
OC=$(JMODELICA)/Compiler/OptimicaCompiler
MCJAR_DIR=$(MC)/bin
OCJAR_DIR=$(OC)/bin
BEAVER_JAR=$(JMODELICA)/ThirdParty/Beaver/beaver-0.9.6.1/lib/beaver.jar


EXE_MOD=modelicaTransfer
EXE_OPT=optimicaTransfer
#To make <SomeModelHeader.hpp> work this path is used. 
MCSRC=../../src
TYPES=$(MCSRC)/types/RealType.cpp $(MCSRC)/types/IntegerType.cpp $(MCSRC)/types/BooleanType.cpp $(MCSRC)/types/UserType.cpp $(MCSRC)/types/PrimitiveType.cpp $(MCSRC)/types/VariableType.cpp 
MODELICA_CASADI_MODELICA = $(MCSRC)/Model.cpp  $(MCSRC)/Equation.cpp $(MCSRC)/DerivativeVariable.cpp $(MCSRC)/RealVariable.cpp $(MCSRC)/IntegerVariable.cpp  $(MCSRC)/BooleanVariable.cpp  $(MCSRC)/Variable.cpp $(MCSRC)/ModelFunction.cpp $(TYPES)
MODEL_FLAGS= $(MODELICA_CASADI_MODELICA) $(MCSRC)/transferModelica.cpp -lcasadi
OPT_FLAGS= $(MODELICA_CASADI_MODELICA) $(MCSRC)/Constraint.cpp $(MCSRC)/OptimizationProblem.cpp $(MCSRC)/transferOptimica.cpp -lcasadi_ipopt_interface -lcasadi_optimal_control -lcasadi_tinyxml -lcasadi_csparse_interface -lcasadi  -lipopt -llapack -ldl -lcoinmumps -lcoinhsl -lblas -lpthread -lgfortran -lm -lgcc_s -lquadmath -lcoinmetis
EXE_MOD_CFLAGS=-ldl -lpthread  
EXE_OPT_CFLAGS=-ldl -lpthread  
CFLAGS=-I$(JAVA_HOME)/include
LIBCASADI=$(CASADI_HOME)/build/lib/libcasadi.so
SEP=:


JARS_MOD=$(MCJAR_DIR)/ModelicaCompiler.jar$(SEP)$(MCJAR_DIR)/util.jar$(SEP)$(BEAVER_JAR)
JARS_OPT=$(OCJAR_DIR)/OptimicaCompiler.jar$(SEP)$(OCJAR_DIR)/util.jar$(SEP)$(BEAVER_JAR)


all: modelica optimizer

# Invoke JCC. List all Java classes that you need to wrap here:
buildMod/:
	rm -rf build
	python -m jcc --classpath $(JARS_MOD):. \
		  java.lang.System \
		  java.util.ArrayList \
		  java.util.Set \
		  java.util.Iterator \
		  java.io.PrintStream \
		  casadi.SX \
		  casadi.MX \
		  casadi.MXFunction \
		  casadi.MXVector \
		  org.jmodelica.util.OptionRegistry \
		  org.jmodelica.modelica.compiler.ModelicaCompiler \
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
				  
buildOpt/:
	rm -rf build
	python -m jcc --classpath $(JARS_OPT):. \
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
		  org.jmodelica.optimica.compiler.FStringComment \
		  org.jmodelica.optimica.compiler.FAttribute \
		  org.jmodelica.optimica.compiler.FDerivedType \
		  org.jmodelica.optimica.compiler.FType \
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

$(EXE_OPT): mainOpt.cpp $(JCC_SRC) $(JCC_H) build/__wrap__.cpp
	g++ -o $(EXE_OPT) mainOpt.cpp  build/__wrap__.cpp \
		$(JCC_SRC) \
		$(LIBCASADI) \
		-L$(CASADI_HOME)/build/lib \
		-Ibuild \
		-I$(JCC) \
		-I$(CASADI_HOME) \
		-I$(BOOST_HOME) \
		-I$(MCSRC) \
		$(EXE_OPT_CFLAGS) $(OPT_FLAGS) $(CFLAGS)

$(EXE_MOD): mainMod.cpp $(JCC_SRC) $(JCC_H) build/__wrap__.cpp
	g++ -o $(EXE_MOD) mainMod.cpp build/__wrap__.cpp \
		$(JCC_SRC) \
		$(LIBCASADI) \
		-L$(CASADI_HOME)/build/lib \
		-Ibuild \
		-I$(JCC) \
		-I$(CASADI_HOME) \
		-I$(BOOST_HOME) \
		-I$(MCSRC) \
		$(EXE_MOD_CFLAGS) $(MODEL_FLAGS) $(CFLAGS)

OptModel:
	echo "#!/bin/sh" > runOpt.sh 
	echo "rm -f res_opt.py" >> runOpt.sh 
	@read -p "Enter model Name:" model;  \
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(MCB)/lib\" ./$(EXE_OPT) $(JARS_OPT) $$model" >> runOpt.sh 
	echo "echo 'Plotting results... .. .'" >> runOpt.sh 
	echo "python res_opt.py &" >> runOpt.sh 
	chmod u+x runOpt.sh	

optimizer: buildOpt $(EXE_OPT) 
	rm -f runOpt.sh
	rm -f res_opt.py
	echo "#!/bin/sh" > runOpt.sh
	echo "rm -f res_opt.py" >> runOpt.sh 
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(MCB)/lib\" ./$(EXE_OPT) $(JARS_OPT)" >> runOpt.sh
	echo "echo 'Plotting results... .. .'" >> runOpt.sh
	echo "python res_opt.py &" >> runOpt.sh
	chmod u+x runOpt.sh

modelica: buildMod $(EXE_MOD)
	echo "#!/bin/sh" > runMod.sh
	echo "LD_LIBRARY_PATH=\"$(CASADI_HOME)/build/lib:$(MCB)/lib\" ./$(EXE_MOD) $(JARS_MOD)" >> runMod.sh
	chmod u+x runMod.sh

clean:
	rm -rf build
	rm -f $(EXE_MOD) runMod.sh
	rm -f $(EXE_OPT) runOpt.sh
	rm -f res_opt.py
test: clean modelica optimizer
	./runMod.sh
	./runOpt.sh

.PHONY: all clean
