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



/** \file fmiModelDescription.h
*  \brief Public interface to the FMI XML C-library.
*/

#ifndef FMIMODELDESCRIPTION_H_
#define FMIMODELDESCRIPTION_H_

#include <stddef.h>
#include <fmi-me-1.0/fmiModelFunctions.h>
#include <fmi-me-1.0/fmiModelTypes.h>

#ifdef __cplusplus
extern "C" {
#endif

/**
 * \defgroup Forward declarations of structs used in the interface.
 */
/*  ModelDescription is the entry point for the package*/
typedef struct fmiModelDescription fmiModelDescription;

/* \defgroup Vendor annotation supporting structures*/
/* @{ */
typedef struct fmiVendorList fmiVendorList;
typedef struct fmiVendor fmiVendor;
typedef struct fmiAnnotation fmiAnnotation;
/* @} */

/* \defgroup  Type definitions supporting structures*/
/* @{ */
typedef struct fmiRealType fmiRealType;
typedef struct fmiIntegerType fmiIntegerType;
typedef struct fmiEnumerationType fmiEnumerationType;
typedef struct fmiVariableType fmiVariableType;

typedef struct fmiTypeDefinitions fmiTypeDefinitions;
/* @} */

/* \defgroup Scalar Variable types */
/* @{ */
/* General variable type is convenien to unify all the variable list operations */
typedef struct fmiVariable fmiVariable;
typedef struct fmiVariableList fmiVariableList;
/* Typed variables are needed to support specific attributes */
typedef struct fmiRealVariable fmiRealVariable;
typedef struct fmiIntegerVariable fmiIntegerVariable;
typedef struct fmiStringVariable fmiStringVariable;
typedef struct fmiEnumerationVariable fmiEnumerationVariable;
typedef struct fmiBooleanVariable fmiBooleanVariable;
/* @} */

/* \defgroup Structures encapsulating unit information */
/* @{ */
typedef struct fmiUnit fmiUnit;
typedef struct fmiDisplayUnit fmiDisplayUnit;
typedef struct fmiUnitDefinitions fmiUnitDefinitions;
/* @} */

/* 
   \brief Allocate the ModelDescription structure and initialize as empty model.
   @return NULL pointer is returned if memory allocation fails.
   @param callbacks - Standard FMI callbacks may be sent into the module. The argument is optional (pointer can be zero).
*/
fmiModelDescription* fmiAllocateModelDescription( fmiCallbackFunctions* callbacks);

/* 
   \brief Parse XML file
   Repeaded calls invalidate the data structures created with the previous call to fmiParseXML,
   i.e., fmiClearModelDescrition is automatically called before reading in the new file.

   @return 0 if parsing was successfull. Non-zero value indicates an error.
*/
int fmiParseXML( fmiModelDescription* md, const char* fileName);

/* 
   Clears the data associated with the model description.
*/
void fmiClearModelDescription( fmiModelDescription* md);

/* fmiIsEmpty returns 1 if model description is empty and 0 if there is some content associated. */
int fmiIsEmpty(fmiModelDescription* md);

/* Error handling: 
  Many functions below return pointers to struct. An error is indicated by returning NULL/0-pointer. 
  If error is returned than fmiGetLastError() functions can be used to retrieve the error message.
  If logging callbacks were specified then the same information is reported via logger.
  Memory for the error string is allocated and deallocated in the module.
  Client code should not store the pointer to the string since it can become invalid.
*/
const char* fmiGetLastError(fmiModelDescription* md);

/* 
fmiClearLastError clears the error message and returns 0 if further processing is possible. If it returns 1 then the 
error was not recoverable. Model desciption should be freed and recreated.
*/
int fmiClearLastError(fmiModelDescription* md);

/* Release the memory allocated */
void fmiFreeModelDescription(fmiModelDescription*);

/* Retrieve general model information */
/* Memory for the strings is allocated and deallocated in the module.*/
const char* fmiGetModelName(fmiModelDescription* md);

const char* fmiGetModelIdentifier(fmiModelDescription* md);

const char* fmiGetGUID(fmiModelDescription* md);

const char* fmiGetDesciption(fmiModelDescription* md);

const char* fmiGetAuthor(fmiModelDescription* md);

const char* fmiGetVersion(fmiModelDescription* md);
const char* fmiGetGenerationTool(fmiModelDescription* md);
const char* fmiGetGenerationDateAndTime(fmiModelDescription* md);

typedef enum _fmiVariableNamingConvension 
{ 
	fmiNamingFlat, 
	fmiNamingStructured
} fmiVariableNamingConvension;

fmiVariableNamingConvension fmiGetNamingConvension(fmiModelDescription* md);

static const char* fmiNamingConvensionToString(fmiVariableNamingConvension convention) {
    if(convention == fmiNamingFlat) return "flat";
    if(convention == fmiNamingStructured) return "structured";
    return "Invalid";
}

unsigned int fmiGetNumberOfContinuousStates(fmiModelDescription* md);

unsigned int fmiGetNumberOfEventIndicators(fmiModelDescription* md);

double fmiGetDefaultExperimentStartTime(fmiModelDescription* md);

void fmiSetDefaultExperimentStartTime(fmiModelDescription* md, double);

double fmiGetDefaultExperimentStopTime(fmiModelDescription* md);

void fmiSetDefaultExperimentStopTime(fmiModelDescription* md, double);

double fmiGetDefaultExperimentTolerance(fmiModelDescription* md);

void fmiSetDefaultExperimentTolerance(fmiModelDescription* md, double);

#include "fmiType.h"
#include "fmiUnit.h"
#include "fmiVariable.h"
#include "fmiVariableList.h"
#include "fmiVendorAnnotations.h"


#endif
