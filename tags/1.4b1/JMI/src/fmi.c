/*
    Copyright (C) 2009 Modelon AB

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

#include "fmiModelFunctions.h"
#include "fmiModelTypes.h"
#include "jmi.h"

/* Creation and destruction of model instances and setting debug status */
DllExport fmiComponent fmiInstantiateModel (fmiString            instanceName,
					    fmiString            GUID,
					    fmiCallbackFunctions functions,
					    fmiBoolean           loggingOn) {
 
}

DllExport void      fmiFreeModelInstance(fmiComponent c) {

}

DllExport fmiStatus fmiSetDebugLogging  (fmiComponent c, fmiBoolean loggingOn) {

}


/* Providing independent variables and re-initialization of caching */
DllExport fmiStatus fmiSetTime                (fmiComponent c, fmiReal time) {

}

DllExport fmiStatus fmiSetContinuousStates    (fmiComponent c, const fmiReal x[], size_t nx) {

}

DllExport fmiStatus fmiCompletedIntegratorStep(fmiComponent c, fmiBoolean* callEventUpdate) {

}

DllExport fmiStatus fmiSetReal                (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiReal    value[]) {

}

DllExport fmiStatus fmiSetInteger             (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiInteger value[]) {

}

DllExport fmiStatus fmiSetBoolean             (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiBoolean value[]) {

}

DllExport fmiStatus fmiSetString              (fmiComponent c, const fmiValueReference vr[], size_t nvr, const fmiString  value[]) {

}


/* Evaluation of the model equations */
DllExport fmiStatus fmiInitialize(fmiComponent c, fmiBoolean toleranceControlled,
				  fmiReal relativeTolerance, fmiEventInfo* eventInfo) {

}

DllExport fmiStatus fmiGetDerivatives    (fmiComponent c, fmiReal derivatives[]    , size_t nx) {

}

DllExport fmiStatus fmiGetEventIndicators(fmiComponent c, fmiReal eventIndicators[], size_t ni) {

}

DllExport fmiStatus fmiGetReal   (fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiReal    value[]) {

}

DllExport fmiStatus fmiGetInteger(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiInteger value[]) {

}

DllExport fmiStatus fmiGetBoolean(fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiBoolean value[]) {

}

DllExport fmiStatus fmiGetString (fmiComponent c, const fmiValueReference vr[], size_t nvr, fmiString  value[]) {

}

DllExport fmiStatus fmiEventUpdate               (fmiComponent c, fmiBoolean intermediateResults, fmiEventInfo* eventInfo) {

}

DllExport fmiStatus fmiGetContinuousStates       (fmiComponent c, fmiReal states[], size_t nx) {

}

DllExport fmiStatus fmiGetNominalContinuousStates(fmiComponent c, fmiReal x_nominal[], size_t nx) {

}

DllExport fmiStatus fmiGetStateValueReferences   (fmiComponent c, fmiValueReference vrx[], size_t nx) {

}

DllExport fmiStatus fmiTerminate                 (fmiComponent c) {

}
