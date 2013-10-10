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
add_library(fmi_me STATIC ${FMI_MESources})

#Install the libraries
install(TARGETS fmi_me DESTINATION "${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
