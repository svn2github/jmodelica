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

add_subdirectory(jcc)

set(CXX_FLAGS "")

# source files
set(TYPES_CPP
  types/RealType.cpp
  types/IntegerType.cpp
  types/BooleanType.cpp
  types/UserType.cpp
  types/PrimitiveType.cpp
  types/VariableType.cpp
)
set(TYPES_HPP
  types/RealType.hpp
  types/IntegerType.hpp
  types/BooleanType.hpp
  types/UserType.hpp
  types/PrimitiveType.hpp
  types/VariableType.hpp
)

set(MC_CPP
  BooleanVariable.cpp
  CompilerOptionsWrapper.cpp
  Constraint.cpp
  DerivativeVariable.cpp
  TimedVariable.cpp
  Equation.cpp
  IntegerVariable.cpp
  Model.cpp
  ModelFunction.cpp
  OptimizationProblem.cpp
  RealVariable.cpp
  sharedTransferFunctionality.cpp
  transferModelica.cpp
  transferOptimica.cpp
  Variable.cpp
  ${TYPES_CPP}
  jcc/initjcc.cpp
  jcc/jccutils.cpp
  jcc/JCCEnv.cpp # todo: Pull these straight from JCC!
  jcc/JObject.cpp
  ${JCC_GEN_DIR}/__wrap__.cpp
)
# MC_HPP is used by the parent script for SWIG dependencies as well
set(MC_HPP
  BooleanVariable.hpp
  CompilerOptionsWrapper.hpp
  Constraint.hpp
  DerivativeVariable.hpp
  TimedVariable.hpp
  Equation.hpp
  IntegerVariable.hpp
  ModelFunction.hpp
  Model.hpp
  OptimizationProblem.hpp
  Printable.hpp
  RealVariable.hpp
  Ref.hpp
  SharedNode.hpp
  sharedTransferFunctionality.hpp
  transferModelica.hpp
  transferOptimica.hpp
  Variable.hpp
  ${TYPES_HPP}
  jcc/initjcc.h
  jcc/jccutils.h
  jcc/sxwrap.hpp
  jcc/mxwrap.hpp
  jcc/mxvectorwrap.hpp
  jcc/mxfunctionwrap.hpp
  jcc/JCCEnv.h # todo: Pull these straight from JCC!
  jcc/JObject.h
  ${MC_PATHS_H}
)
# Make the paths absolute since they are exported to the parent script
make_paths_absolute(MC_HPP "${MC_HPP}")


# compiler options
if(CMAKE_COMPILER_IS_GNUCXX)
  set(CXX_FLAGS ${CXX_FLAGS} -fPIC)
endif(CMAKE_COMPILER_IS_GNUCXX)

set_source_files_properties(${JCC_GEN_DIR}/__wrap__.cpp PROPERTIES
  GENERATED ON)

add_library(ModelicaCasADi ${MC_CPP} ${MC_HPP})
set_target_properties(ModelicaCasADi PROPERTIES COMPILE_FLAGS ${CXX_FLAGS})
add_dependencies(ModelicaCasADi jcc_gen)
