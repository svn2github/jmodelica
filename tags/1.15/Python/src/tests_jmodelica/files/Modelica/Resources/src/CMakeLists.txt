#    Copyright (C) 2014 Modelon AB

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License version 3 as published
#    by the Free Software Foundation, or optionally, under the terms of the
#    Common Public License version 1.0 as published by IBM.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License, or the Common Public License, for more details.

#    You should have received copies of the GNU General Public License
#    and the Common Public License along with this program.  If not,
#    see <http://www.gnu.org/licenses/> or
#    <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.

# NOTE: CMake 2.8.6 is required since this is the version used in development.
# The script is KNOWN NOT TO WORK WITH 2.8.3 and below (ExternalProject 
# interface changes). CMake 2.8.4 and 2.8.5 are not tested.
cmake_minimum_required (VERSION 2.8.6 FATAL_ERROR)

set(ADDNUMBERS_Sources
    addNumbers.c
    ../Include/addNumbers.h
)

set(ARRAYFUNCTIONS_Sources
    arrayFunctions.c
    ../Include/arrayFunctions.h
)

set(EXTERNALFUNCTIONSC_Sources
    externalFunctionsC.c
    ../Include/externalFunctionsC.h
)

set(EXTOBJECTS_Sources
    extObjects.c
    ../Include/extObjects.h
)

set(USEMODELICAERROR_Sources
    useModelicaError.c
    ../Include/useModelicaError.h
)

set(EXTERNALFUNCTIONSFORTRAN_Sources
    externalFunctionsFortran.f
)

#Build addNumbers library
add_library(addNumbers STATIC ${ADDNUMBERS_Sources})
if(NOT MSVC)
    set_target_properties(addNumbers PROPERTIES COMPILE_FLAGS "-Wall -g -Werror -O2")
endif()

#Build arrayFunctions library
add_library(arrayFunctions STATIC ${ARRAYFUNCTIONS_Sources})
if(NOT MSVC)
    set_target_properties(arrayFunctions PROPERTIES COMPILE_FLAGS "-Wall -g -Werror -O2")
endif()

#Build externalFunctionsC library
add_library(externalFunctionsC STATIC ${EXTERNALFUNCTIONSC_Sources})
if(NOT MSVC)
    set_target_properties(externalFunctionsC PROPERTIES COMPILE_FLAGS "-Wall -g -Werror -O2")
endif()

#Build extObjects library
add_library(extObjects STATIC ${EXTOBJECTS_Sources})
if(NOT MSVC)
    set_target_properties(extObjects PROPERTIES COMPILE_FLAGS "-Wall -g -Werror -O2")
endif()

#Build useModelicaError library
add_library(useModelicaError STATIC ${USEMODELICAERROR_Sources})
if(NOT MSVC)
    set_target_properties(useModelicaError PROPERTIES COMPILE_FLAGS "-Wall -g -Werror -O2")
endif()

#Build externalFunctionsFortran library
add_library(externalFunctionsFortran STATIC ${EXTERNALFUNCTIONSFORTRAN_Sources})

#Install the libraries
install(TARGETS addNumbers DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS arrayFunctions DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS externalFunctionsC DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS extObjects DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS useModelicaError DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")
install(TARGETS externalFunctionsFortran DESTINATION "${TEST_LIBRARY_INSTALL_DIR}")

#Install header files
#install(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/"
#    DESTINATION "${TEST_LIBRARY_INSTALL_DIR}/../Include"
#    FILES_MATCHING PATTERN "*.h")
