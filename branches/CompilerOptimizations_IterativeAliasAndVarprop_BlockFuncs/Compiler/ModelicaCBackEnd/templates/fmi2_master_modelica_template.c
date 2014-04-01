/*
    Copyright (C) 2013 Modelon AB

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

/* Run-time. */
#include "stdio.h"
#include "stdlib.h"
#include "math.h"
#include "jmi.h"
#include "jmi_block_residual.h"
#include "jmi_log.h"
#include "ModelicaUtilities.h"
#include "ModelicaStandardTables.h"

#include "fmi2_me.h"
#include "fmi2_cs.h"
#include "fmiFunctions.h"
#include "fmiFunctionTypes.h"
#include "fmiTypesPlatform.h"

/* Generated code. */
$INCLUDE: fmi_code_gen_template.c$

/* FMI Funcitons. */
$INCLUDE: fmi2_functions_common_template.c$
#ifdef FMUME20
$INCLUDE: fmi2_functions_me_template.c$
#endif
#ifdef FMUCS20
$INCLUDE: fmi2_functions_cs_template.c$
#endif

/* Helper function for instantiating the FMU. */
int can_instantiate(fmiType fmuType, fmiString instanceName,
                    const fmiCallbackFunctions* functions) {
    if (fmuType == fmiCoSimulation) {
#ifndef FMUCS20
        functions->logger(0, instanceName, fmiError, "ERROR", "The model is not compiled as a Co-Simulation FMU.");
        return 0;
#endif
    } else if (fmuType == fmiModelExchange) {
#ifndef FMUME20
        functions->logger(0, instanceName, fmiError, "ERROR", "The model is not compiled as a Model Exchange FMU.");
        return 0;
#endif
    }
    return 1;
}
