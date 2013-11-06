cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

if(NOT TOP_SRC)    
    set(TOP_SRC ${CMAKE_CURRENT_SOURCE_DIR}/../../../)
    message(STATUS "TOP_SRC was not defined, using ${TOP_SRC}")
endif()
set(MSLCSOURCES ${TOP_SRC}/ThirdParty/MSL/Modelica/Resources/C-Sources)
message(STATUS MSLCSOURCES=${MSLCSOURCES})

set(JMISources
	
    jmi.h
    jmi_array_common.h
    jmi_array_none.h
    jmi_block_residual.h
    jmi_cs.h
    jmi_kinsol_solver.h
    jmi_linear_solver.h
    jmi_me.h
    jmi_simple_newton.h
    jmi_ode_cvode.h
    jmi_ode_euler.h
    jmi_ode_solver.h
    jmi_ode_problem.h
    jmi_util.h
    jmi_log.h
    jmi_global.h
    
    jmi.c
    jmi_array_none.c
    jmi_block_residual.c
    jmi_cs.c
    jmi_kinsol_solver.c
    jmi_linear_solver.c
    jmi_me.c
    jmi_simple_newton.c
    jmi_util.c
    jmi_log.c
    jmi_global.c
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

#Build ModelicaExternalC library
include_directories(${MSLCSOURCES})
include_directories(${MSLCSOURCES}/zlib)
add_library(ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})

#Build ModelicaStandardTables library
add_definitions("-DDUMMY_FUNCTION_USERTAB -DHAVE_ZLIB")
add_library(ModelicaStandardTables STATIC ${STANDARDTABLESSources})

#Install the libraries
install(TARGETS jmi ModelicaExternalC ModelicaStandardTables
    DESTINATION "${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
    
install(FILES "${MSLCSOURCES}/ModelicaStandardTables.h"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary")

