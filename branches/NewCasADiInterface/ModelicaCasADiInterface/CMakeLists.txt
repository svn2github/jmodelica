cmake_minimum_required(VERSION 2.8.6)
project(ModelicaCasADi CXX)


add_definitions(-DMODELICACASADI_WITH_SWIG) # todo: might not always want this...


function(make_paths_absolute DEST_VAR DIRS)  
  set(ABS_DIRS "")
  foreach(DIR ${DIRS})
    get_filename_component(ABS_DIR ${DIR} ABSOLUTE)
    list(APPEND ABS_DIRS ${ABS_DIR})
  endforeach(DIR)
  set(${DEST_VAR} "${ABS_DIRS}" PARENT_SCOPE)
endfunction()

function(join OUTPUT GLUE VALUES)
  string (REPLACE ";" "${GLUE}" _TMP_STR "${VALUES}")
  set (${OUTPUT} "${_TMP_STR}" PARENT_SCOPE)
endfunction()

function(interleave_string_and_list DEST_VAR STRING)  
  set(RESULT "")
  foreach(ITEM ${ARGN})
    list(APPEND RESULT ${STRING} ${ITEM})
  endforeach(ITEM)
  set(${DEST_VAR} "${RESULT}" PARENT_SCOPE)
endfunction()

function(interleave_string_and_list DEST_VAR STRING)  
  set(RESULT "")
  foreach(ITEM ${ARGN})
    list(APPEND RESULT ${STRING} ${ITEM})
  endforeach(ITEM)
  set(${DEST_VAR} "${RESULT}" PARENT_SCOPE)
endfunction()


# Todo: better way to choose path separator?
if(WIN32)
  set(SEP ;)
else(WIN32)
  set(SEP :)
endif(WIN32)

# import environment variables
set(CASADI_HOME $ENV{CASADI_HOME})
set(CASADI_BUILD_DIR $ENV{CASADI_BUILD_DIR})
set(MC_BUILD $ENV{MC_BUILD})
set(IPOPT_HOME $ENV{IPOPT_HOME})
set(BOOST_HOME $ENV{BOOST_HOME})
set(JAVA_HOME $ENV{JAVA_HOME})

# Add library path for libs
link_directories(${CASADI_BUILD_DIR}/lib) 
link_directories(${IPOPT_HOME}/lib) 

get_filename_component(ABS_MC_BUILD "${MC_BUILD}" REALPATH)
set(JMODELICA "${ABS_MC_BUILD}/JModelica.org")

foreach(Target Modelica Optimica)
  string(TOLOWER ${Target} target)
  set(COMPILER_${target} "${JMODELICA}")
  set(COMPILER_${target}_JAR_DIR "${JMODELICA}/jars/${target}")
  set(JARS_${target} "${COMPILER_${target}_JAR_DIR}/${Target}Compiler.jar" "${COMPILER_${target}_JAR_DIR}/util.jar")
endforeach(Target)

set(JARS "${JMODELICA}/jars/beaver.jar" ${JARS_modelica} ${JARS_optimica})
set(JARS_AND_JNI ${JARS} "${JAVA_HOME}/include" "${JAVA_HOME}/include/win32")

set(CLASSPATH ${JARS_AND_JNI})
interleave_string_and_list(CLASSPATH_WITH_PREFIX --classpath ${JARS})

if(NOT WIN32)
  join(CLASSPATH "${SEP}" "${JARS_AND_JNI}")
endif(NOT WIN32)

find_library(CASADI_DLL
  NAMES libcasadi.so libcasadi.dll
  PATHS ${CASADI_BUILD_DIR}/lib
  NO_DEFAULT_PATH
)

# generate modelicacasadi_paths.h
if(WIN32)
  set(CLASSPATH ${JARS} "${JAVA_HOME}/include" "${JAVA_HOME}/include/win32")
  set(LIBPATH ${MC_BUILD}/casadi/lib;${JMODELICA}/lib)
else(WIN32)
  join(CLASSPATH ":" "${JARS}")
  set(LIBPATH ${MC_BUILD}/casadi/lib:${JMODELICA}/lib)
endif(WIN32)
set(MC_PATHS_H "${CMAKE_CURRENT_BINARY_DIR}/modelicacasadi_paths.h")
include_directories("${CMAKE_CURRENT_BINARY_DIR}")
set(MODELPATH "${CMAKE_CURRENT_SOURCE_DIR}/test/common")

message(STATUS "CLASSPATH=${CLASSPATH}")
message(STATUS "CASADI_HOME=${CASADI_HOME}")
message(STATUS "LIBPATH=${LIBPATH}")

# uses MODELPATH, LIBPATH, and CLASSPATH (inherited from parent)
configure_file (
  src/modelicacasadi_paths.h.in
  ${MC_PATHS_H}
)

# Set up includes etc. used by both src/ and swig/
# Add library path for libs
link_directories(${MC_BUILD}/casadi/lib) 
link_directories(${IPOPT_HOME}/lib) 

include_directories(src src/jcc)
include_directories(${CASADI_HOME})
#JNI
include_directories(${JAVA_HOME}/include)
if(WIN32)
  include_directories(${JAVA_HOME}/include/win32)
endif(WIN32)
#Boost
include_directories(${BOOST_HOME})

set(JCC_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/src/jcc/build")
include_directories(${JCC_GEN_DIR})
MESSAGE(STATUS "wrap = ${JCC_GEN_DIR}/__wrap__.cpp")


add_subdirectory(src)

get_directory_property(MC_HPP
  DIRECTORY src
  DEFINITION MC_HPP
)

add_subdirectory(test EXCLUDE_FROM_ALL)
add_subdirectory(swig EXCLUDE_FROM_ALL)



# INCLUDE_DIRS may be used by the parent script
# TODO: remove this once we only use a standalone python wrapper
get_directory_property(INCLUDE_DIRS
  DIRECTORY src
  INCLUDE_DIRECTORIES
)
make_paths_absolute(INCLUDE_DIRS "${INCLUDE_DIRS}")
