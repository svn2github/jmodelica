cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(FMI_CSSources

    fmiCSFunctions.h
	fmiCSPlatformTypes.h
    fmi1_cs.h
    
    fmi1_cs.c
)

#Build fmi_cs library
add_library(fmi1_cs STATIC ${FMI_CSSources})
set_target_properties(fmi1_cs PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror")

#Install the libraries
install(TARGETS fmi1_cs DESTINATION "${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
