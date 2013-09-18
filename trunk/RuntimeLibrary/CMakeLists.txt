cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (SimulationRuntime)

# Get the JModelica install directory
set(JMODELICA_HOME ${CMAKE_INSTALL_DIR})
message(STATUS JMODELICA_HOME=${JMODELICA_HOME})

#Make directory for header files to be installed in.
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory 
                ${JMODELICA_HOME}/include/RuntimeLibrary)
                
#Make directory for lib files to be installed in.
execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory 
                ${JMODELICA_HOME}/lib/RuntimeLibrary)

if(NOT(WIN32 OR CYGWIN OR APPLE))
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_SHARED_LIBRARY_C_FLAGS}")
    SET(WITH_PIC ON)
endif()

#Including Sundials.
set(RuntimeLibrary_BUILD ${SimulationRuntime_BINARY_DIR})
set(SundialsDir ${RuntimeLibrary_BUILD}/../../sundials_install)
message(STATUS SundialsDir=${SundialsDir})
include_directories(${SundialsDir}/include)

include_directories(src/fmi_cs)
include_directories(src/fmi_me)
include_directories(src/jmi)
add_subdirectory(src/fmi_cs)
add_subdirectory(src/fmi_me)
add_subdirectory(src/jmi)
