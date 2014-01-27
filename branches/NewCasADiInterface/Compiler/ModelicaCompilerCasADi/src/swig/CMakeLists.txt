cmake_minimum_required(VERSION 2.8.6)
project(ModelicaCompilerCasADi CXX)

#	swig -outdir $(MC_SRC)/src/java-generated/casadi \
#             -o $(MC_SRC)/src/cpp-generated/java_casadi_wrap.cxx \
#	     -java -package casadi -c++ -I$(CASADI_HOME) $(MC_SRC)/src/swig/java_casadi.i


# copied from ModelicaCasadiInterface/CMakeLists.txt

# import environment variables
set(CASADI_HOME $ENV{CASADI_HOME})
set(CASADI_BUILD_DIR $ENV{CASADI_BUILD_DIR})
set(JAVA_HOME $ENV{JAVA_HOME})

find_library(CASADI_DLL
  NAMES libcasadi.so libcasadi.dll
  PATHS ${CASADI_BUILD_DIR}/lib
  NO_DEFAULT_PATH
)

#JNI
include_directories(${JAVA_HOME}/include)
if(WIN32)
  include_directories(${JAVA_HOME}/include/win32)
endif(WIN32)


set(CPPFLAGS -fPIC -shared -D_REENTRANT)
if(WIN32)
  set(LINKFLAGS "-shared -Wl,--add-stdcall-alias")
else(WIN32)
  set(LINKFLAGS -shared)
endif(WIN32)


set(MODULE_NAME ifcasadi)

add_definitions(${CPPFLAGS})
include_directories(${CASADI_HOME})
include_directories(${CASADI_HOME}/swig)

set(CMAKE_SWIG_OUTDIR ${CMAKE_CURRENT_LIST_DIR}/../java-generated/casadi)

find_package(SWIG REQUIRED)
include(UseSWIG)

set(CMAKE_SWIG_FLAGS -package casadi)

set_source_files_properties(java_casadi.i PROPERTIES CPLUSPLUS ON)

swig_add_module(${MODULE_NAME} java java_casadi.i)
swig_link_libraries(${MODULE_NAME} ${CASADI_DLL})
  
if(WIN32)
  set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
    PROPERTIES LINK_FLAGS "${LINKFLAGS}")
  set_target_properties(${SWIG_MODULE_${MODULE_NAME}_REAL_NAME}
    PROPERTIES PREFIX "")
endif(WIN32)


# Expose the SWIG module under a nicely named build target
add_custom_target(swig-ifcasadi
  DEPENDS ${SWIG_MODULE_${MODULE_NAME}_REAL_NAME})
