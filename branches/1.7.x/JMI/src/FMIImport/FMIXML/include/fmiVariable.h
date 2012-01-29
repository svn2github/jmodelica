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



/** \file fmiVariable.h
*  \brief Public interface to the FMI XML C-library. Handling of model variables.
*/

#ifndef FMIVARIABLE_H_
#define FMIVARIABLE_H_

#include "fmiModelDescription.h"
#include "fmiType.h"


#ifdef __cplusplus
extern "C" {
#endif

const char* fmiGetVariableName(fmiVariable*);
const char* fmiGetVariableDescription(fmiVariable*);

fmiValueReference fmiGetVariableValueReference(fmiVariable*);

/*
    For scalar variable gives the type definition is present
*/
fmiVariableType* fmiGetVariableDeclaredType(fmiVariable*);
fmiBaseType fmiGetVariableBaseType(fmiVariable*);

int   fmiGetVariableHasStart(fmiVariable*);
int   fmiGetVariableIsFixed(fmiVariable*);

typedef enum _fmiVariability {
	fmiVariabilityConstant,	
	fmiVariabilityParameter,
	fmiVariabilityDiscrete,
	fmiVariabilityContinuous
} fmiVariability;

const char* fmiVariabilityToString(fmiVariability v);

fmiVariability fmiGetVariability(fmiVariable*);

typedef enum _fmiCausality {
	fmiCausalityInput,	
	fmiCausalityOutput,	
	fmiCausalityInternal,	
	fmiCausalityNone
} fmiCausality;

const char* fmiCausalityToString(fmiCausality c);

fmiCausality fmiGetCausality(fmiVariable*);

/* DirectDependency is returned for variables with causality Output. Null pointer for others. */
fmiVariableList* fmiGetDirectDependency(fmiVariable*);

fmiRealVariable* fmiGetVariableAsReal(fmiVariable*);
fmiIntegerVariable* fmiGetVariableAsInteger(fmiVariable*);
fmiEnumerationVariable* fmiGetVariableAsEnumeration(fmiVariable*);
fmiStringVariable* fmiGetVariableAsString(fmiVariable*);
fmiBooleanVariable* fmiGetVariableAsBoolean(fmiVariable*);

fmiReal fmiGetRealVariableStart(fmiRealVariable* v);
fmiReal fmiGetRealVariableMax(fmiRealVariable* v);
fmiReal fmiGetRealVariableMin(fmiRealVariable* v);
fmiReal fmiGetRealVariableNominal(fmiRealVariable* v);
fmiUnit* fmiGetRealVariableUnit(fmiRealVariable* v);
fmiDisplayUnit* fmiGetRealVariableDisplayUnit(fmiRealVariable* v);

const char* fmiGetStringVariableStart(fmiStringVariable* v);
fmiBoolean fmiGetBooleanVariableStart(fmiBooleanVariable* v);

fmiInteger fmiGetIntegerVariableStart(fmiIntegerVariable* v);
fmiInteger fmiGetIntegerVariableMin(fmiIntegerVariable* v);
fmiInteger fmiGetIntegerVariableMax(fmiIntegerVariable* v);

fmiInteger fmiGetEnumVariableStart(fmiEnumerationVariable* v);
fmiInteger fmiGetEnumVariableMin(fmiEnumerationVariable* v);
fmiInteger fmiGetEnumVariableMax(fmiEnumerationVariable* v);

#ifdef __cplusplus
}
#endif
#endif
