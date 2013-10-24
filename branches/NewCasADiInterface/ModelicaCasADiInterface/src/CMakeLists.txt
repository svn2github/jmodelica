
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
  CompilerOptionsWrapper.cpp
  Constraint.cpp
  OptimizationProblem.cpp
  Model.cpp
  DerivativeVariable.cpp
  RealVariable.cpp
  IntegerVariable.cpp
  BooleanVariable.cpp
  Variable.cpp
  Equation.cpp
  ModelFunction.cpp
  transferModelica.cpp
  transferOptimica.cpp
  sharedTransferFunctionality.cpp
  ${TYPES_CPP}
  jcc/initjcc.cpp
  jcc/jccutils.cpp
  jcc/JCCEnv.cpp # todo: Pull these straight from JCC!
  jcc/JObject.cpp
  ${JCC_GEN_DIR}/__wrap__.cpp
)
set(MC_HPP
  AttributeExpression.hpp
  BooleanVariable.hpp
  Constraint.hpp
  DerivativeVariable.hpp
  Equation.hpp
  IntegerVariable.hpp
  ModelFunction.hpp
  Model.hpp
  OptimizationProblem.hpp
  RealVariable.hpp
  transferModelica.hpp
  transferOptimica.hpp
  sharedTransferFunctionality.hpp
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

# compiler options
if(CMAKE_COMPILER_IS_GNUCXX)
  set(CXX_FLAGS ${CXX_FLAGS} -fPIC)
endif(CMAKE_COMPILER_IS_GNUCXX)

set_source_files_properties(${JCC_GEN_DIR}/__wrap__.cpp PROPERTIES
  GENERATED ON)

add_library(ModelicaCasADi ${MC_CPP} ${MC_HPP})
set_target_properties(ModelicaCasADi PROPERTIES COMPILE_FLAGS ${CXX_FLAGS})
add_dependencies(ModelicaCasADi jcc_gen)
