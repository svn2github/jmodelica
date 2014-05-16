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

if(NOT TOP_SRC)
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()
set(MSLCSOURCES ${TOP_SRC}/ThirdParty/MSL/Modelica/Resources/C-Sources)
message(STATUS MSLCSOURCES=${MSLCSOURCES})

set(JMISources   
    jmi.h
    jmi_array_none.h
    jmi_block_residual.h
    jmi_me.h
    jmi_util.h
    jmi_global.h
    
    jmi_util.c
    jmi_global.c
    jmi.c
    jmi_array_none.c
    jmi_block_residual.c
    jmi_cs.c
    jmi_me.c

    # Logging sources
	jmi_callbacks.h
    jmi_log.h
    jmi_log_impl.h
    jmi_log.c

    # Block solver sources
    jmi_block_solver.h
    jmi_block_solver_impl.h
    jmi_kinsol_solver.h
    jmi_brent_solver.h
    jmi_minpack_solver.h
    jmi_linear_solver.h
    jmi_simple_newton.h

    jmi_block_solver.c
    jmi_kinsol_solver.c
    jmi_brent_solver.c
    jmi_minpack_solver.c
    jmi_linear_solver.c
    jmi_simple_newton.c

    # Co-simulation support sources
    jmi_cs.h    
    jmi_ode_cvode.h
    jmi_ode_euler.h
    jmi_ode_solver.h
    jmi_ode_problem.h
    
    jmi_ode_cvode.c
    jmi_ode_euler.c
    jmi_ode_solver.c
    jmi_ode_problem.c
)

set(MODELICAEXTERNALCSources
    jmi_global.h
    ModelicaUtilities.h
    
    jmi_global.c
    ModelicaUtilities.c
    
    ${MSLCSOURCES}/ModelicaInternal.c
    ${MSLCSOURCES}/ModelicaStrings.c
)

set(STANDARDTABLESSources
    ${MSLCSOURCES}/ModelicaStandardTables.c
    ${MSLCSOURCES}/ModelicaMatIO.c
    ${MSLCSOURCES}/zlib/adler32.c
    ${MSLCSOURCES}/zlib/compress.c
    ${MSLCSOURCES}/zlib/crc32.c
    ${MSLCSOURCES}/zlib/deflate.c
    ${MSLCSOURCES}/zlib/gzclose.c
    ${MSLCSOURCES}/zlib/gzlib.c
    ${MSLCSOURCES}/zlib/gzread.c
    ${MSLCSOURCES}/zlib/gzwrite.c
    ${MSLCSOURCES}/zlib/infback.c
    ${MSLCSOURCES}/zlib/inffast.c
    ${MSLCSOURCES}/zlib/inflate.c
    ${MSLCSOURCES}/zlib/inftrees.c
    ${MSLCSOURCES}/zlib/trees.c
    ${MSLCSOURCES}/zlib/uncompr.c
    ${MSLCSOURCES}/zlib/zutil.c
)
#Build jmi library
add_library(jmi STATIC ${JMISources})
if(NOT MSVC)
    set_target_properties(jmi PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror -Wno-long-long -O2")
    if (WIN32)
        include_directories(${TOP_SRC}/ThirdParty/pthreads/include)
    endif()
endif()

if(WIN32)
    #Flag that is needed for compiling lib togheter with MINPACK, no dll is created.
    add_definitions(-DCMINPACK_NO_DLL)
endif()

if(JMI_SUNDIALS AND JMI_LAPACK AND JMI_MINPACK)
    add_executable(jmi_block_solver_test jmi_block_solver_test.c)
    target_link_libraries(jmi_block_solver_test jmi ${JMI_SUNDIALS} ${JMI_LAPACK} ${JMI_MINPACK})
endif()

#Build ModelicaExternalC library
include_directories(${MSLCSOURCES})
include_directories(${MSLCSOURCES}/zlib)
add_library(ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})
if(NOT MSVC)
    set_target_properties(ModelicaExternalC PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic")
endif()

#Build ModelicaStandardTables library
add_definitions("-DDUMMY_FUNCTION_USERTAB -DHAVE_ZLIB")
add_library(ModelicaStandardTables STATIC ${STANDARDTABLESSources})
if(NOT MSVC)
    set_target_properties(ModelicaStandardTables PROPERTIES COMPILE_FLAGS "-Wall -g")
endif()

#Install the libraries
install(TARGETS jmi ModelicaExternalC ModelicaStandardTables
    DESTINATION "${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
    
install(FILES "${MSLCSOURCES}/ModelicaStandardTables.h"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary")

