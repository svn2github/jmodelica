set(HEADERS
    ../fmi-me-1.0/fmiModelFunctions.h
    ../fmi-me-1.0/fmiModelTypes.h
    include/fmiModelDescription.h
    src/fmiModelDescriptionImpl.h
    src/fmiXMLParser.h

    include/fmiType.h
    src/fmiTypeImpl.h
    include/fmiUnit.h
    src/fmiUnitImpl.h
    include/fmiVendorAnnotations.h
    src/fmiVendorAnnotationsImpl.h
    include/fmiVariable.h
    src/fmiVariableImpl.h
    include/fmiVariableList.h
    src/fmiVariableListImpl.h

    src/fmiCallbacks.h
 )

set(SOURCE
    src/fmiXMLParser.c
    src/fmiCallbacks.c
    src/fmiModelDescription.c
    src/fmiType.c
    src/fmiUnit.c
    src/fmiVendorAnnotations.c
    src/fmiVariable.c
    src/fmiVariableList.c
)

include_directories("../Utils" ".." "include")

add_library(fmixml ${SOURCE} ${HEADERS})
