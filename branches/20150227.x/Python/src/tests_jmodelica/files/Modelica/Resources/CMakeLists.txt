#    Copyright (C) 2014 Modelon AB

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3 as published
#    by the Free Software Foundation, or optionally, under the terms of the
#    Common Public License version 1.0 as published by IBM.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License, or the Common Public License, for more details.

#    You should have received copies of the GNU General Public License
#    and the Common Public License along with this program.  If not,
#    see <http://www.gnu.org/licenses/> or
#    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.

# NOTE: CMake 2.8.6 is required since this is the version used in development.
# The script is KNOWN NOT TO WORK WITH 2.8.3 and below (ExternalProject 
# interface changes). CMake 2.8.4 and 2.8.5 are not tested.
cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (TestLibraries C Fortran)

#Inputs through flags
add_definitions(-DTOP_SRC)
if(NOT TOP_SRC)
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()

# Get the JModelica install directory
if(CMAKE_INSTALL_DIR)
    set(JMODELICA_INSTALL_DIR ${CMAKE_INSTALL_DIR})
else()
    set(JMODELICA_INSTALL_DIR "${TOP_SRC}/../install")
    message(STATUS "Install dir not defined, using ${JMODELICA_INSTALL_DIR}")
endif()    
message(STATUS JMODELICA_INSTALL_DIR=${JMODELICA_INSTALL_DIR})

# Get platform information
if(CMAKE_HOST_WIN32) #Set to true when the host system is Windows and on cygwin.
    set(JM_PLATFORM win)
elseif(CMAKE_HOST_APPLE) #Set to true when the host system is Apple OSX. 
    set(JM_PLATFORM darwin)
elseif(CMAKE_HOST_UNIX) #Set to true when the host system is UNIX or UNIX like (i.e. APPLE and CYGWIN). 
    set(JM_PLATFORM linux)
else(CMAKE_HOST_WIN32)
    message(SEND_ERROR "Target platform is not supported by the tests")
set(JM_PLATFORM not_supported)
endif()
if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(JM_PLATFORM "${JM_PLATFORM}32")
else()
    set(JM_PLATFORM "${JM_PLATFORM}64")
endif()


#Make the directory for header files to be installed in. 
file(MAKE_DIRECTORY ${JMODELICA_INSTALL_DIR}/Python/tests_jmodelica/files/Modelica/Resources/Include/)

#Make the directory for lib files to be installed in.
set(TEST_LIBRARY_INSTALL_DIR ${JMODELICA_INSTALL_DIR}/Python/tests_jmodelica/files/Modelica/Resources/Library/${JM_PLATFORM})
file(MAKE_DIRECTORY ${TEST_LIBRARY_INSTALL_DIR})

if(NOT(WIN32 OR CYGWIN OR APPLE))
    SET(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${CMAKE_SHARED_LIBRARY_C_FLAGS}")
    SET(WITH_PIC ON)
elseif(MSVC)
    add_definitions(/D _CRT_SECURE_NO_WARNINGS)
endif()

#Add test libraries
include_directories(Include)
include_directories(${TOP_SRC}/JMI/src)
add_subdirectory(src)

