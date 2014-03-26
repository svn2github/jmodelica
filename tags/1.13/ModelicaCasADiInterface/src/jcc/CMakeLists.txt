#Copyright (C) 2013 Modelon AB

#This program is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, version 3 of the License.

#This program is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.

#You should have received a copy of the GNU General Public License
#along with this program.  If not, see <http://www.gnu.org/licenses/>.




# NB: The target jcc_gen has to be cleaned and rebuilt if the lists of classes
# to be wrapped below are changed.

set(CLASSES_common
  java.lang.System
  java.lang.Object
  java.util.ArrayList
  casadi.MX
  casadi.MXFunction
  casadi.MXVector
  org.jmodelica.util.OptionRegistry
)

set(CLASSES_modelica
  org.jmodelica.modelica.compiler.AliasManager
  org.jmodelica.modelica.compiler.ModelicaCompiler
  org.jmodelica.modelica.compiler.FDerivedType
  org.jmodelica.modelica.compiler.FType
  org.jmodelica.modelica.compiler.FAttribute
  org.jmodelica.modelica.compiler.FStringComment
  org.jmodelica.modelica.compiler.SourceRoot
  org.jmodelica.modelica.compiler.InstClassDecl
  org.jmodelica.modelica.compiler.FClass
  org.jmodelica.modelica.compiler.List
  org.jmodelica.modelica.compiler.FAbstractEquation
  org.jmodelica.modelica.compiler.FEquation
  org.jmodelica.modelica.compiler.FFunctionCallEquation
  org.jmodelica.modelica.compiler.FFunctionCallLeft
  org.jmodelica.modelica.compiler.FExp
  org.jmodelica.modelica.compiler.FIdUse
  org.jmodelica.modelica.compiler.FIdUseExp
  org.jmodelica.modelica.compiler.FVariable
  org.jmodelica.modelica.compiler.FRealVariable
  org.jmodelica.modelica.compiler.FDerivativeVariable
  org.jmodelica.modelica.compiler.FFunctionCall
  org.jmodelica.modelica.compiler.FFunctionDecl
  org.jmodelica.modelica.compiler.FAssignStmt
  org.jmodelica.modelica.compiler.FFunctionCallStmt
  org.jmodelica.modelica.compiler.FFunctionVariable
  org.jmodelica.modelica.compiler.FAlgorithm 
)

# todo: consolidate with CLASSES_modelica
set(CLASSES_optimica
  org.jmodelica.optimica.compiler.AliasManager
  org.jmodelica.optimica.compiler.OptimicaCompiler
  org.jmodelica.optimica.compiler.FStringComment
  org.jmodelica.optimica.compiler.FAttribute
  org.jmodelica.optimica.compiler.FDerivedType
  org.jmodelica.optimica.compiler.FType
  org.jmodelica.optimica.compiler.FAttribute
  org.jmodelica.optimica.compiler.SourceRoot
  org.jmodelica.optimica.compiler.InstClassDecl
  org.jmodelica.optimica.compiler.FClass
  org.jmodelica.optimica.compiler.FOptClass
  org.jmodelica.optimica.compiler.FConstraint
  org.jmodelica.optimica.compiler.FRelationConstraint
  org.jmodelica.optimica.compiler.FConstraintEq
  org.jmodelica.optimica.compiler.FConstraintLeq
  org.jmodelica.optimica.compiler.FConstraintGeq
  org.jmodelica.optimica.compiler.List
  org.jmodelica.optimica.compiler.FAbstractEquation
  org.jmodelica.optimica.compiler.FEquation
  org.jmodelica.optimica.compiler.FFunctionCallEquation
  org.jmodelica.optimica.compiler.FFunctionCallLeft
  org.jmodelica.optimica.compiler.FExp
  org.jmodelica.optimica.compiler.FIdUse
  org.jmodelica.optimica.compiler.FIdUseExp
  org.jmodelica.optimica.compiler.FVariable
  org.jmodelica.optimica.compiler.FRealVariable
  org.jmodelica.optimica.compiler.FDerivativeVariable
  org.jmodelica.optimica.compiler.FTimedVariable
  org.jmodelica.optimica.compiler.FFunctionCall
  org.jmodelica.optimica.compiler.FVectorFunctionCall
  org.jmodelica.optimica.compiler.FFunctionDecl
  org.jmodelica.optimica.compiler.FAssignStmt
  org.jmodelica.optimica.compiler.FIfStmt
  org.jmodelica.optimica.compiler.FFunctionCallStmt
  org.jmodelica.optimica.compiler.FFunctionVariable
  org.jmodelica.optimica.compiler.FAlgorithm 
  org.jmodelica.optimica.compiler.BaseNode
  org.jmodelica.optimica.compiler.Root
)


set(CLASSES ${CLASSES_common} ${CLASSES_modelica} ${CLASSES_optimica})
#message(STATUS "CLASSES=${CLASSES}")

add_custom_command(
  OUTPUT ${JCC_GEN_DIR} ${JCC_GEN_DIR}/__wrap__.cpp
  COMMAND ${CMAKE_COMMAND} -E chdir ${CMAKE_CURRENT_BINARY_DIR}
    python -m jcc ${CLASSPATH_WITH_PREFIX} ${CLASSES} ${JCC_EXTRA_ARGS} # JCC_EXTRA_ARGS provided by parent scipts
  DEPENDS ${JARS}
#          ${CMAKE_CURRENT_LIST_FILE} ${JARS} # seems to force rebuild each time
)
add_custom_target(jcc_gen ALL DEPENDS ${JCC_GEN_DIR} ${JCC_GEN_DIR}/__wrap__.cpp)
