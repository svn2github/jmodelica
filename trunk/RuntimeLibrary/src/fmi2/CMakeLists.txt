cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(STANDARD_HEADER_SRC ${TOP_SRC}/ThirdParty/FMI/2.0)
message(STATUS STANDARD_HEADER_SRC=${STANDARD_HEADER_SRC})

set(FMISources
    
    ${STANDARD_HEADER_SRC}/fmiFunctionTypes.h
    ${STANDARD_HEADER_SRC}/fmiTypesPlatform.h
    ${STANDARD_HEADER_SRC}/fmiFunctions.h
    
    fmi2_common.h
    fmi2_me.h
    fmi2_cs.h
    
    fmi2_common.c
	fmi2_me.c
    fmi2_cs.c
)
#Build fmi2 library
include_directories(${STANDARD_HEADER_SRC})
add_library(fmi2 STATIC ${FMISources})

#Install the libraries
install(TARGETS fmi2 DESTINATION "${JMODELICA_INSTALL_DIR}/lib/RuntimeLibrary")

#Install header files
install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
    DESTINATION "${JMODELICA_INSTALL_DIR}/include/RuntimeLibrary"
    FILES_MATCHING PATTERN "*.h")
