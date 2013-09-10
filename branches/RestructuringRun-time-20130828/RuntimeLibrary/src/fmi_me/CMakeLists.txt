cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(FMI_MESources
    fmiModelFunctions.h
    fmiModelTypes.h
    fmi1_me.h
    
	fmi1_me.c
)

add_library(jm_fmi_me STATIC ${FMI_MESources})

install(TARGETS jm_fmi_me DESTINATION "${JMODELICA_HOME}/lib")

install(DIRECTORY "${CMAKE_CURRENT_COURCE_DIR}"
    DESTINATION "${JMODELICA_HOME}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
