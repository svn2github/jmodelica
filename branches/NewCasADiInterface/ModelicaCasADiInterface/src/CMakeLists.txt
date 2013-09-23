
add_subdirectory(jcc)

set(CXX_FLAGS "")

get_directory_property(JCC_GEN_DIR
  DIRECTORY jcc
  DEFINITION JCC_GEN_DIR
)
message(STATUS "JCC_GEN_DIR=${JCC_GEN_DIR}")


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

# set up target
include_directories(. jcc)
include_directories(${JCC_GEN_DIR})

include_directories(${CASADI_HOME})
#include_directories(${CASADI_HOME}/swig)
include_directories(${BOOST_HOME})

include_directories(${JAVA_HOME}/include)

set_source_files_properties(${JCC_GEN_DIR}/__wrap__.cpp PROPERTIES
  GENERATED ON)


add_library(ModelicaCasADi ${MC_CPP} ${MC_HPP})
set_target_properties(ModelicaCasADi PROPERTIES COMPILE_FLAGS ${CXX_FLAGS})
add_dependencies(ModelicaCasADi jcc_gen)
