cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(RuntimeLibrary_SRC ${SimulationRuntime_SOURCE_DIR})
set(MSLCSOURCES ${RuntimeLibrary_SRC}/../ThirdParty/MSL/Modelica/Resources/C-Sources)
message(STATUS MSLCSOURCES=${MSLCSOURCES})

set(JMISources
	fmi1_functions.h
	fmi1_types.h
	
    jmi.h
    jmi_array_common.h
    jmi_array_none.h
    jmi_block_residual.h
    jmi_common.h
    jmi_kinsol_solver.h
    jmi_linear_solver.h
    jmi_simple_newton.h
    jmi_ode_cvode.h
    jmi_ode_euler.h
    jmi_ode_solver.h
    jmi_util.h
    jmi_log.h
    jmi_global.h
    
    jmi.c
    jmi_array_none.c
    jmi_block_residual.c
    jmi_common.c
    jmi_kinsol_solver.c
    jmi_linear_solver.c
    jmi_simple_newton.c
    jmi_util.c
    jmi_log.c
    jmi_global.c
    jmi_ode_cvode.c
    jmi_ode_euler.c
    jmi_ode_solver.c
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

add_library(jmi STATIC ${JMISources})
include_directories(${MSLCSOURCES})
add_library(ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})
add_definitions("-DDUMMY_FUNCTION_USERTAB -DHAVE_ZLIB")
add_library(ModelicaStandardTables STATIC ${STANDARDTABLESSources})

install(TARGETS jmi ModelicaExternalC ModelicaStandardTables
    DESTINATION "${JMODELICA_HOME}/lib/RuntimeLibrary")

install(DIRECTORY "${CMAKE_CURRENT_COURCE_DIR}"
    DESTINATION "${JMODELICA_HOME}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
    
install(FILES "${MSLCSOURCES}/ModelicaStandardTables.h"
    DESTINATION "${JMODELICA_HOME}/include/RuntimeLibrary")

