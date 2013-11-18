cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(FMI_MESources

    fmi1_functions.h
	fmi1_types.h

    fmiModelFunctions.h
    fmiModelTypes.h
    fmi1_me.h
    
	fmi1_me.c
)
#Build fmi_me library
add_library(fmi1_me STATIC ${FMI_MESources})
set_target_properties(fmi1_me PROPERTIES COMPILE_FLAGS "-Wall -g -std=c89 -pedantic -Werror")

#Install the libraries
install(TARGETS fmi1_me DESTINATION "${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
