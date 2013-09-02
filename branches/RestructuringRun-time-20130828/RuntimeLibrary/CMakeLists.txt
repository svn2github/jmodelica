cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (SimulationRuntime)

# Get the JModelica directory and change "\" for "/"
set(JMODELICA_HOME "$ENV{JMODELICA_HOME}")
STRING(REGEX REPLACE "\\\\" "/" JMODELICA_HOME ${JMODELICA_HOME} )


#Including Sundials.
set(SundialsDir ${JMODELICA_HOME}/../build/sundials_install)
include_directories(${SundialsDir}/include)

include_directories(src/jmi)
include_directories(src/fmi_me)
include_directories(src/fmi_cs)
add_subdirectory(src/fmi_cs)
add_subdirectory(src/fmi_me)
add_subdirectory(src/jmi)
