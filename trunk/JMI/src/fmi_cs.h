/*
    Copyright (C) 2011 Modelon AB

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

/** \file fmi_cs.h
 *  \brief The public FMI co-simulation interface.
 **/

#ifndef fmi_cs_h
#define fmi_cs_h

#include "fmiCSFunctions.h"
/* #include "jmi.h" */

/**
 * \defgroup fmi_cs_public Public functions of the Functional Mock-up Interface for co-simulation.
 *
 * \brief Documentation of the public functions and data structures
 * of the Functional Mock-up Interface for co-simulation.
 */

/* @{ */

#ifdef __cplusplus
extern "C" {
#endif


/**
 * \brief Do a step
 *
 * ...add documentation...
 *
 * @return Error code.
 */
fmiStatus fmi_cs_do_step(fmiComponent c,
						 fmiReal currentCommunicationPoint,
                         fmiReal communicationStepSize,
                         fmiBoolean   newStep);

/* @} */

#ifdef __cplusplus
}
#endif
#endif
