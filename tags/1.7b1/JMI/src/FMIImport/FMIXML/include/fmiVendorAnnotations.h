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

/** \file fmiVendorAnnotations.h
*  \brief Public interface to the FMI XML C-library. Handling of vendor annotations.
*/

#ifndef FMIVENDORANNOTATIONS_H_
#define FMIVENDORANNOTATIONS_H_

#include "fmiModelDescription.h"

#ifdef __cplusplus
extern "C" {
#endif

/* Basic support for vendor annotations. */

fmiVendorList* fmiGetVendorList(fmiModelDescription* md);

unsigned int  fmiGetNumberOfVendors(fmiVendorList*);

fmiVendor* fmiGetVendor(fmiVendorList*, unsigned int  index);

/* fmiVendor* fmiAddVendor(fmiModelDescription* md, char* name);

void* fmiRemoveVendor(fmiVendor*); */

const char* fmiGetVendorName(fmiVendor*);

unsigned int  fmiGetNumberOfVendorAnnotations(fmiVendor*);

/*Note: Annotations can be used in other places but have common interface name-value */
fmiAnnotation* fmiGetVendorAnnotation(fmiVendor*, unsigned int  index);

const char* fmiGetAnnotationName(fmiAnnotation*);

const char* fmiGetAnnotationValue(fmiAnnotation*);

/* fmiAnnotation* fmiAddVendorAnnotation(fmiVendor*, const char* name, const char* value);

fmiAnnotation* fmiRemoveVendorAnnotation(fmiVendor*, const char* name, const char* value);
*/

#ifdef __cplusplus
}
#endif
#endif
