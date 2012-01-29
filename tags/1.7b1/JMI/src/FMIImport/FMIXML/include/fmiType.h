/*
   Copyright (C) 2012 Modelon AB

   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as published
   by the Free Software Foundation, or optionally, under the terms of the
   Common Public License version 1.0 as published by IBM.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License, or the Common Public License, for more details.

   You should have received copies of the GNU General Public License
   and the Common Public License along with this program.  If not,
   see <http://www.gnu.org/licenses/> or
   <http://www.ibm.com/developerworks/library/os-cpl.html/> respectively.
*/



/** \file fmiType.h
*  \brief Public interface to the FMI XML C-library: variable types handling.
*/

#ifndef FMITYPE_H_
#define FMITYPE_H_

#include "fmiModelDescription.h"

#ifdef __cplusplus
extern "C" {
#endif

/* \defgroup Support for processing variable types */

fmiDisplayUnit* fmiGetTypeDisplayUnit(fmiRealType*);

fmiTypeDefinitions* fmiGetTypeDefinitions(fmiModelDescription* md);

/* Base types used in type definitions */
typedef enum _fmiBaseType
{
        fmiBaseTypeReal,
        fmiBaseTypeInteger,
        fmiBaseTypeBoolean,
        fmiBaseTypeString,
        fmiBaseTypeEnumeration
} fmiBaseType;

/* Convert base type constant to string */
const char* fmiConvertBaseTypeToString(fmiBaseType bt);

size_t fmiGetTypeDefinitionsNumber(fmiTypeDefinitions* td);

fmiVariableType* fmiGetTypeDefinition(fmiTypeDefinitions* td, unsigned int  index);

const char* fmiGetTypeName(fmiVariableType*);

/* Note that NULL pointer is returned if the attribute is not present in the XML.*/
const char* fmiGetTypeDescription(fmiVariableType*);

fmiBaseType fmiGetBaseType(fmiVariableType*);

/* Boolean and String has no extra attributes -> not needed*/

fmiRealType* fmiGetTypeAsReal(fmiVariableType*);
fmiIntegerType* fmiGetTypeAsInteger(fmiVariableType*);
fmiEnumerationType* fmiGetTypeAsEnum(fmiVariableType*);

/* Note that NULL-pointer is always returned for strings and booleans */
const char* fmiGetTypeQuantity(fmiVariableType*);

fmiReal fmiGetRealTypeMin(fmiRealType*);
fmiReal fmiGetRealTypeMax(fmiRealType*);
fmiReal fmiGetRealTypeNominal(fmiRealType*);
fmiUnit* fmiGetRealTypeUnit(fmiRealType*);
int fmiGetRealTypeIsRelativeQuantity(fmiRealType*);

fmiInteger fmiGetIntegerTypeMin(fmiIntegerType*);
fmiInteger fmiGetIntegerTypeMax(fmiIntegerType*);

fmiInteger fmiGetEnumTypeMin(fmiEnumerationType*);
fmiInteger fmiGetEnumTypeMax(fmiEnumerationType*);
unsigned int  fmiGetEnumTypeSize(fmiEnumerationType*);
const char* fmiGetEnumTypeItemName(fmiEnumerationType*, unsigned int  item);

#ifdef __cplusplus
}
#endif
#endif
const char* fmiGetEnumTypeItemDescription(fmiEnumerationType*, unsigned int  item);

