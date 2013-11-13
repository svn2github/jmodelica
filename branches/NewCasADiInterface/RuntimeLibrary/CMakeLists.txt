cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (SimulationRuntime)

#Inputs through flags
add_definitions(-DTOP_SRC)
add_definitions(-DSUNDIALS_HOME)

# Get the JModelica install directory
set(JMODELICA_INSTALL_DIR ${CMAKE_INSTALL_DIR})
message(STATUS JMODELICA_INSTALL_DIR=${JMODELICA_INSTALL_DIR})

#Make the directory for header files to be installed in.
file(MAKE_DIRECTORY ${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary)
                
#Make the directory for lib files to be installed in.
file(MAKE_DIRECTORY ${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary)

if(NOT(WIN32 OR CYGWIN OR APPLE))
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_SHARED_LIBRARY_C_FLAGS}")
    SET(WITH_PIC ON)
elseif(MSVC)
    add_definitions(/D _CRT_SECURE_NO_WARNINGS)
endif()

#Including Sundials.
message(STATUS SUNDIALS_HOME=${SUNDIALS_HOME})
include_directories(${SUNDIALS_HOME}/include)

set(RuntimeLibrary_BUILD ${SimulationRuntime_BINARY_DIR})

#Add jmi
add_subdirectory(src/jmi)

#Add fmi2
include_directories(src/jmi)
add_subdirectory(src/fmi2)

#Add fmi1_me
add_subdirectory(src/fmi1_me)

#Add fmi1_cs
include_directories(src/fmi1_me)
add_subdirectory(src/fmi1_cs)





