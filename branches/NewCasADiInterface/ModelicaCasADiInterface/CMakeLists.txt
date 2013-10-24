cmake_minimum_required(VERSION 2.8.6)
project(ModelicaCasADi CXX)


function(make_dirs_absolute DEST_VAR DIRS)  
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


# Todo: better way to choose path separator?
if(WIN32)
  set(SEP ;)
else(WIN32)
  set(SEP :)
endif(WIN32)

# import environment variables
set(CASADI_HOME $ENV{CASADI_HOME})
set(MC_BUILD $ENV{MC_BUILD})
set(IPOPT_HOME $ENV{IPOPT_HOME})
set(BOOST_HOME $ENV{BOOST_HOME})
set(JAVA_HOME $ENV{JAVA_HOME})

# LIBS is used by the test directory
set(LIBS "${MC_BUILD}/casadi/lib/libcasadi.so" -ldl -lpthread)

# Add library path for libs
link_directories(${MC_BUILD}/casadi/lib) 
link_directories(${IPOPT_HOME}/lib) 

get_filename_component(ABS_MC_BUILD "${MC_BUILD}" REALPATH)
set(JMODELICA "${ABS_MC_BUILD}/JModelica.org")

# todo: this might not allways be the place to find Beaver?
set(BEAVER_JAR "${JMODELICA}/jars/beaver.jar")

foreach(Target Modelica Optimica)
  string(TOLOWER ${Target} target)
  set(COMPILER_${target} "${JMODELICA}")
  set(COMPILER_${target}_JAR_DIR "${JMODELICA}/jars/${target}")
  set(JARS_${target} "${COMPILER_${target}_JAR_DIR}/${Target}Compiler.jar" "${COMPILER_${target}_JAR_DIR}/util.jar")
endforeach(Target)

set(JARS_common "${BEAVER_JAR}")

set(JARS ${JARS_common} ${JARS_modelica} ${JARS_optimica})
join(CLASSPATH "${SEP}" "${JARS}")


# generate modelicacasadi_paths.h
set(MC_PATHS_H "${CMAKE_CURRENT_BINARY_DIR}/modelicacasadi_paths.h")
include_directories("${CMAKE_CURRENT_BINARY_DIR}")
set(LIBPATH ${JMODELICA}/lib)
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
include_directories(src src/jcc)
include_directories(${CASADI_HOME})
include_directories(${BOOST_HOME})
include_directories(${JAVA_HOME}/include)

set(JCC_GEN_DIR "${CMAKE_CURRENT_BINARY_DIR}/src/jcc/build")
include_directories(${JCC_GEN_DIR})
MESSAGE(STATUS "wrap = ${JCC_GEN_DIR}/__wrap__.cpp")


add_subdirectory(src)

add_subdirectory(test EXCLUDE_FROM_ALL)



# INCLUDE_DIRS may be used by the parent script
# TODO: remove this and the make_dirs_absolute function once we only use
# a standalone python wrapper
get_directory_property(INCLUDE_DIRS
  DIRECTORY src
  INCLUDE_DIRECTORIES
)
make_dirs_absolute(INCLUDE_DIRS "${INCLUDE_DIRS}")
