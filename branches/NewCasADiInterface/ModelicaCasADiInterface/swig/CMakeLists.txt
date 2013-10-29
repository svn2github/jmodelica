set(MODULE_NAME modelicacasadi_wrapper)
set(CASADI_INTERFACE_DEPS doc.i ModelicaCasADi.i Ref.i)


find_package(SWIG REQUIRED)
include(UseSWIG)

find_package(PythonLibs)
include_directories(${PYTHON_INCLUDE_PATH})

set(CMAKE_SWIG_FLAGS "")

include_directories(${CASADI_HOME}/swig)

set_source_files_properties(casadi_interface.i PROPERTIES CPLUSPLUS ON)
set(SWIG_MODULE_${MODULE_NAME}_EXTRA_DEPS ${CASADI_INTERFACE_DEPS} ${MC_HPP})

swig_add_module(${MODULE_NAME} python casadi_interface.i)
swig_link_libraries(${MODULE_NAME} ModelicaCasADi ${PYTHON_LIBRARIES})
swig_link_libraries(${MODULE_NAME} ${CASADI_DLL})


# Expose the SWIG module under a nicely named build target
add_custom_target(modelicacasadi_wrapper
  DEPENDS ${SWIG_MODULE_${MODULE_NAME}_REAL_NAME})
set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
  PROPERTIES LINK_FLAGS -shared)
