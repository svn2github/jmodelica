cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(FMI_MESources

    fmi1_functions.h
	fmi1_types.h

    fmiModelFunctions.h
    fmiModelTypes.h
    fmi1_me.h
    
	fmi1_me.c
)

add_library(fmi_me STATIC ${FMI_MESources})

install(TARGETS fmi_me DESTINATION "${JMODELICA_HOME}/lib/RuntimeLibrary")

install(DIRECTORY "" #Files from current directory
    DESTINATION "${JMODELICA_HOME}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
