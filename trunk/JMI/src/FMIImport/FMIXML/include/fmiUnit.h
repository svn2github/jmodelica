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

/** \file fmiUnit.h
*  \brief Public interface to the FMI XML C-library. Handling of variable units.
*/

#ifndef FMIUNIT_H_
#define FMIUNIT_H_

#include "fmiModelDescription.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Support for processing variable units */
fmiUnitDefinitions* fmiGetUnitDefinitions(fmiModelDescription* md);
unsigned int  fmiGetUnitDefinitionsNumber(fmiUnitDefinitions*);
fmiUnit* fmiGetUnit(fmiUnitDefinitions*, unsigned int  index);
const char* fmiGetUnitName(fmiUnit*);

fmiDisplayUnit* fmiGetTypeDisplayUnit(fmiRealType*);
fmiUnit* fmiGetBaseUnit(fmiDisplayUnit*);
const char* fmiGetDisplayUnitName(fmiDisplayUnit*);
fmiReal fmiGetDisplayUnitGain(fmiDisplayUnit*);
fmiReal fmiGetDisplayUnitOffset(fmiDisplayUnit*);

/* TODO: check which way */
fmiReal fmiConvertToDisplayUnit(fmiReal, fmiDisplayUnit*, int isRelativeQuantity);
fmiReal fmiConvertFromDisplayUnit(fmiReal, fmiDisplayUnit*, int isRelativeQuantity);

#ifdef __cplusplus
}
#endif
#endif
