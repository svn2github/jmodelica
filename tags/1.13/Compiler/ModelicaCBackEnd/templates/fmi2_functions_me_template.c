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

/* FMI 2.0 functions specific for ME.*/

FMI_Export fmiStatus fmiEnterEventMode(fmiComponent c) {
	return fmi2_enter_event_mode(c);
}

FMI_Export fmiStatus fmiNewDiscreteStates(fmiComponent  c,
                                          fmiEventInfo* fmiEventInfo) {
	return fmi2_new_discrete_state(c, fmiEventInfo);
}

FMI_Export fmiStatus fmiEnterContinuousTimeMode(fmiComponent c) {
	return fmi2_enter_continuous_time_mode(c);
}

FMI_Export fmiStatus fmiCompletedIntegratorStep(fmiComponent c,
                                                fmiBoolean   noSetFMUStatePriorToCurrentPoint, 
                                                fmiBoolean*  enterEventMode, 
                                                fmiBoolean*   terminateSimulation) {
	return fmi2_completed_integrator_step(c, noSetFMUStatePriorToCurrentPoint,
                                          enterEventMode, terminateSimulation);
}

FMI_Export fmiStatus fmiSetTime(fmiComponent c, fmiReal time) {
	return fmi2_set_time(c, time);
}

FMI_Export fmiStatus fmiSetContinuousStates(fmiComponent c, const fmiReal x[],
                                            size_t nx) {
	return fmi2_set_continuous_states(c, x, nx);
}

FMI_Export fmiStatus fmiGetDerivatives(fmiComponent c, fmiReal derivatives[],
                                       size_t nx) {
	return fmi2_get_derivatives(c, derivatives, nx);
}

FMI_Export fmiStatus fmiGetEventIndicators(fmiComponent c, 
                                           fmiReal eventIndicators[], size_t ni) {
	return fmi2_get_event_indicators(c, eventIndicators, ni);
}

FMI_Export fmiStatus fmiGetContinuousStates(fmiComponent c, fmiReal x[],
                                            size_t nx) {
	return fmi2_get_continuous_states(c, x, nx);
}

FMI_Export fmiStatus fmiGetNominalsOfContinuousStates(fmiComponent c, 
                                                      fmiReal x_nominal[], 
                                                      size_t nx) {
	return fmi2_get_nominals_of_continuous_states(c, x_nominal, nx);
}
