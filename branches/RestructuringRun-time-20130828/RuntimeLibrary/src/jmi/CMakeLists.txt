cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(MSLCSOURCES ${JMODELICA_HOME}/../src/ThirdParty/MSL/Modelica/Resources/C-Sources)

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

add_library(jm_jmi STATIC ${JMISources})
add_library(jm_ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})

install(TARGETS jm_jmi jm_ModelicaExternalC
    DESTINATION "${JMODELICA_HOME}/lib")


