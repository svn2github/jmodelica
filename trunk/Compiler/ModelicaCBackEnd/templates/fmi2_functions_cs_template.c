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

/* FMI 2.0 functions specific for CS.*/

DllExport fmiStatus fmiSetRealInputDerivatives(fmiComponent c, 
                                               const fmiValueReference vr[],
                                               size_t nvr, const fmiInteger order[],
                                               const fmiReal value[]) {
	return fmi2_set_real_input_derivatives(c, vr, nvr, order, value);
}

DllExport fmiStatus fmiGetRealOutputDerivatives(fmiComponent c,
                                                const fmiValueReference vr[],
                                                size_t nvr, const fmiInteger order[],
                                                fmiReal value[]) {
	return fmi2_get_real_output_derivatives(c, vr, nvr, order, value);
}

DllExport fmiStatus fmiDoStep(fmiComponent c, fmiReal currentCommunicationPoint,
                              fmiReal    communicationStepSize,
                              fmiBoolean noSetFMUStatePriorToCurrentPoint) {
	return fmi2_do_step(c, currentCommunicationPoint, communicationStepSize,
                        noSetFMUStatePriorToCurrentPoint);
}

DllExport fmiStatus fmiCancelStep(fmiComponent c) {
	return fmi2_cancel_step(c);
}

DllExport fmiStatus fmiGetStatus(fmiComponent c, const fmiStatusKind s,
                                 fmiStatus* value) {
	return fmi2_get_status(c, s, value);
}

DllExport fmiStatus fmiGetRealStatus(fmiComponent c, const fmiStatusKind s,
                                     fmiReal* value) {
	return fmi2_get_real_status(c, s, value);
}

DllExport fmiStatus fmiGetIntegerStatus(fmiComponent c, const fmiStatusKind s,
                                        fmiInteger* values) {
	return fmi2_get_integer_status(c, s, values);
}

DllExport fmiStatus fmiGetBooleanStatus(fmiComponent c, const fmiStatusKind s,
                                        fmiBoolean* value) {
	return fmi2_get_boolean_status(c, s, value);
}

DllExport fmiStatus fmiGetStringStatus(fmiComponent c, const fmiStatusKind s,
                                       fmiString* value) {
	return fmi2_get_string_status(c, s, value);
	
}
