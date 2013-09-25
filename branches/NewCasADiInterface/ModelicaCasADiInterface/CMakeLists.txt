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
set(BOOST_HOME $ENV{BOOST_HOME})
set(JAVA_HOME $ENV{JAVA_HOME})

# LIBS is used by the test directory
set(LIBS "${CASADI_HOME}/build/lib/libcasadi.so" -ldl -lpthread)

# Add library path for libs
link_directories(${CASADI_HOME}/build/lib) 

get_filename_component(JM_CASADI_BACKEND "../build/ModelicaCasADiInterfaceBuild" REALPATH)
set(JMODELICA "${JM_CASADI_BACKEND}/JModelica.org")

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


add_subdirectory(src)

# INCLUDE_DIRS is used by the test directory
# and may be used by the parent script
get_directory_property(INCLUDE_DIRS
  DIRECTORY src
  INCLUDE_DIRECTORIES
)
make_dirs_absolute(INCLUDE_DIRS "${INCLUDE_DIRS}")


add_subdirectory(test)


