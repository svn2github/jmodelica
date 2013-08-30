
cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

project (SimulationRuntime)


# Get the JModelica directory
set(JMODELICA_SRC_DIR "C:/JModelica.org-SDK-1.8.1/src")
set(MSLCSOURCES ${JMODELICA_SRC_DIR}/ThirdParty/MSL/Modelica/Resources/C-Sources)
message(STATUS "JMODELICA_SRC_DIR = ${JMODELICA_SRC_DIR}")

set(JMIPath "C:/JModelica.org-SDK-1.8.1/src/RuntimeLibrary/RuntimeLibrary/src")

set(ALLSources
    ${JMIPath}/fmiModelFunctions.h
    ${JMIPath}/fmiModelTypes.h
	
	${JMIPath}/fmi1_cs.h
	${JMIPath}/fmi1_functions.h
	${JMIPath}/fmi1_me.h
	${JMIPath}/fmi1_types.h
	${JMIPath}/fmiCSFunctions.h
	${JMIPath}/fmiCSPlatformTypes.h
	
    ${JMIPath}/jmi.h    
    ${JMIPath}/jmi_array_common.h    
    ${JMIPath}/jmi_array_none.h    
    ${JMIPath}/jmi_block_residual.h    
    ${JMIPath}/jmi_common.h    
    ${JMIPath}/jmi_kinsol_solver.h    
    ${JMIPath}/jmi_linear_solver.h    
    ${JMIPath}/jmi_simple_newton.h    
    ${JMIPath}/jmi_util.h    
    ${JMIPath}/jmi_log.h    
    ${JMIPath}/ModelicaUtilities.h    
    
    ${JMIPath}/jmi.c    
    ${JMIPath}/jmi_array_none.c    
    ${JMIPath}/jmi_block_residual.c    
    ${JMIPath}/jmi_common.c    
    ${JMIPath}/jmi_kinsol_solver.c    
    ${JMIPath}/jmi_linear_solver.c    
    ${JMIPath}/jmi_simple_newton.c    
    ${JMIPath}/jmi_util.c    
    ${JMIPath}/jmi_log.c    
    ${JMIPath}/ModelicaUtilities.c    	 

    ${JMIPath}/fmi1_cs.c
    ${JMIPath}/fmi1_me.c
    ${JMIPath}/jmi_init_opt.c
    ${JMIPath}/jmi_ode_cvode.c
    ${JMIPath}/jmi_ode_euler.c
    ${JMIPath}/jmi_ode_solver.c
    ${JMIPath}/jmi_opt_coll.c
    ${JMIPath}/jmi_opt_coll_radau.c
    ${JMIPath}/jmi_simple_newton.c
    ${JMIPath}/jmi_util.c
    ${JMIPath}/ModelicaUtilities.c

    ${JMIPath}/jmi_global.c
    ${JMIPath}/jmi_global.h
)



set(JMISources
	${JMIPath}/fmi1_functions.h
	${JMIPath}/fmi1_types.h
	
    ${JMIPath}/jmi.h  
    ${JMIPath}/jmi_array_common.h
    ${JMIPath}/jmi_array_none.h
    ${JMIPath}/jmi_block_residual.h
    ${JMIPath}/jmi_common.h
    ${JMIPath}/jmi_kinsol_solver.h    
    ${JMIPath}/jmi_linear_solver.h    
    ${JMIPath}/jmi_simple_newton.h
    ${JMIPath}/jmi_ode_cvode.h
    ${JMIPath}/jmi_ode_euler.h
    ${JMIPath}/jmi_ode_solver.h
    ${JMIPath}/jmi_util.h
    ${JMIPath}/jmi_log.h
    
    ${JMIPath}/jmi.c
    ${JMIPath}/jmi_array_none.c
    ${JMIPath}/jmi_block_residual.c
    ${JMIPath}/jmi_common.c
    ${JMIPath}/jmi_kinsol_solver.c
    ${JMIPath}/jmi_linear_solver.c
    ${JMIPath}/jmi_simple_newton.c
    ${JMIPath}/jmi_util.c
    ${JMIPath}/jmi_log.c
    
    ${JMIPath}/jmi_ode_cvode.c
    ${JMIPath}/jmi_ode_euler.c
    ${JMIPath}/jmi_ode_solver.c
    ${JMIPath}/jmi_opt_coll.c #Should this one be removed? Optimaization.
    ${JMIPath}/jmi_simple_newton.c
    ${JMIPath}/jmi_util.c

    ${JMIPath}/jmi_global.c
    ${JMIPath}/jmi_global.h
    
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinpinv.c
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinpinv.h
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod.c
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod.h
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod_impl.h
)

set(JMI_ALGORITHMSources
    ${JMIPath}/jmi_init_opt.c
    ${JMIPath}/jmi_opt_coll.c
    ${JMIPath}/jmi_opt_coll_radau.c
    
    ${JMIPath}/jmi_init_opt.h
    ${JMIPath}/jmi_opt_coll.h
)

set(FMI_MESources
    ${JMIPath}/fmiModelFunctions.h
    ${JMIPath}/fmiModelTypes.h
    
    ${JMIPath}/jmi.h
    ${JMIPath}/fmi1_me.h
    
	${JMIPath}/fmi1_me.c
    
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinpinv.c
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinpinv.h
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod.c
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod.h
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod_impl.h
)

set(FMI_CSSources
    ${JMIPath}/fmiCSFunctions.h
	${JMIPath}/fmiCSPlatformTypes.h
	
    ${JMIPath}/jmi.h
    ${JMIPath}/fmi1_cs.h
    
    ${JMIPath}/fmi1_cs.c
    
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinpinv.c
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinpinv.h
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod.c
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod.h
    ${JMODELICA_SRC_DIR}/external/Assimulo/src/lib/kinsol_jmod_impl.h
)

set(MODELICAEXTERNALCSources

    ${JMIPath}/jmi_global.h
    ${JMIPath}/ModelicaUtilities.h
    
    ${JMIPath}/jmi_global.c
    ${JMIPath}/ModelicaUtilities.c
    
    ${MSLCSOURCES}/ModelicaInternal.c
    ${MSLCSOURCES}/ModelicaStrings.c
)

set(SHARED_LIBRARY_PATH ${CMAKE_CURRENT_BINARY_DIR}/${CMAKE_CFG_INTDIR}/${SHARED_LIBRARY_NAME})

add_library(jm_jmi STATIC ${JMISources})
add_library(jm_fmi_me STATIC ${FMI_MESources})
add_library(jm_fmi_cs STATIC ${FMI_CSSources})
add_library(jm_ModelicaExternalC STATIC ${MODELICAEXTERNALCSources})

#Including Sundials.
set(SundialsDir "C:/JModelica.org-SDK-1.8.1/build/sundials_install/")
include_directories(${SundialsDir}/include)

install(TARGETS jm_jmi jm_fmi_me jm_fmi_cs jm_ModelicaExternalC
    DESTINATION C:/JModelica.org-SDK-1.8.1/install/lib)

#Install the Makefile with autotools instead.
#install(TARGETS Makefiles/Makefile
#    DESTINATION C:/JModelica.org-SDK-1.8.1/install/Makefiles)


