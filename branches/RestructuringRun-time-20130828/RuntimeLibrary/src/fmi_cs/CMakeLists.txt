cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(FMI_CSSources
    fmiCSFunctions.h
	fmiCSPlatformTypes.h
    fmi1_cs.h
    
    fmi1_cs.c
)

add_library(jm_fmi_cs STATIC ${FMI_CSSources})

install(TARGETS jm_fmi_cs DESTINATION "${JMODELICA_HOME}/lib")

install(DIRECTORY "${CMAKE_CURRENT_COURCE_DIR}"
    DESTINATION "${JMODELICA_HOME}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
