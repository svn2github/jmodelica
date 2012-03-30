/*
    Copyright (C) 2012 Modelon AB

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, version 3 of the License.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

#ifndef FMI1_IMPORT_CAPABILITIES_H
#define FMI1_IMPORT_CAPABILITIES_H

#ifdef __cplusplus
extern "C" {
#endif

#include "FMI1/fmi1_import.h"

int fmi1_import_get_canHandleVariableCommunicationStepSize(fmi1_import_capabilities_t* );
int fmi1_import_get_canHandleEvents(fmi1_import_capabilities_t* );
int fmi1_import_get_canRejectSteps(fmi1_import_capabilities_t* );
int fmi1_import_get_canInterpolateInputs(fmi1_import_capabilities_t* );
unsigned int fmi1_import_get_maxOutputDerivativeOrder(fmi1_import_capabilities_t* );
int fmi1_import_get_canRunAsynchronuously(fmi1_import_capabilities_t* );
int fmi1_import_get_canSignalEvents(fmi1_import_capabilities_t* );
int fmi1_import_get_canBeInstantiatedOnlyOncePerProcess(fmi1_import_capabilities_t* );
int fmi1_import_get_canNotUseMemoryManagementFunctions(fmi1_import_capabilities_t* );

#ifdef __cplusplus
}
#endif
#endif /* FMI1_IMPORT_CAPABILITIES_H */
