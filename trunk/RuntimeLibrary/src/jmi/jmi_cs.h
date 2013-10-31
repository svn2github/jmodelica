/*
    Copyright (C) 2013 Modelon AB

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

#ifndef jmi_cs_h
#define jmi_cs_h

#include "jmi.h"

/*
fmiStatus fmi2_set_real_input_derivatives(fmiComponent c, 
                                          const fmiValueReference vr[],
                                          size_t nvr, const fmiInteger order[],
                                          const fmiReal value[]);

fmiStatus fmi2_get_real_output_derivatives(fmiComponent c,
                                           const fmiValueReference vr[],
                                           size_t nvr, const fmiInteger order[],
                                           fmiReal value[]);

fmiStatus fmi2_do_step(fmiComponent c, fmiReal currentCommunicationPoint,
                       fmiReal    communicationStepSize,
                       fmiBoolean noSetFMUStatePriorToCurrentPoint);

fmiStatus fmi2_cancel_step(fmiComponent c);

fmiStatus fmi2_get_status(fmiComponent c, const fmiStatusKind s,
                          fmiStatus* value);

fmiStatus fmi2_get_real_status(fmiComponent c, const fmiStatusKind s,
                               fmiReal* value);
fmiStatus fmi2_get_integer_status(fmiComponent c, const fmiStatusKind s,
                                  fmiInteger* values);

fmiStatus fmi2_get_boolean_status(fmiComponent c, const fmiStatusKind s,
                                  fmiBoolean* value);


fmiStatus fmi2_get_string_status(fmiComponent c, const fmiStatusKind s,
                                 fmiString* value);
*/
#endif
