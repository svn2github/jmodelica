cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (SimulationRuntime)

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
endif()

#Including Sundials.
add_definitions(-DSUNDIALS_HOME)
message(STATUS SUNDIALS_HOME=${SUNDIALS_HOME})
include_directories(${SUNDIALS_HOME}/include)

set(RuntimeLibrary_BUILD ${SimulationRuntime_BINARY_DIR})

#Add jmi
add_subdirectory(src/jmi)

#Add fmi_me
include_directories(src/jmi)
add_subdirectory(src/fmi_me)

#Add fmi_cs
include_directories(src/fmi_me)
add_subdirectory(src/fmi_cs)





