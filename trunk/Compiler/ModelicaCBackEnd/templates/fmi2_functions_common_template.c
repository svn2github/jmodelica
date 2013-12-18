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


/* FMI 2.0 functions common for both ME and CS.*/

FMI_Export const char* fmiGetTypesPlatform() {
    return fmi2_get_types_platform();
}

FMI_Export const char* fmiGetVersion() {
    return fmi2_get_version();
}

FMI_Export fmiStatus fmiSetDebugLogging(fmiComponent    c,
                                        fmiBoolean      loggingOn, 
                                        size_t          nCategories, 
                                        const fmiString categories[]) {
    return fmi2_set_debug_logging(c, loggingOn, nCategories, categories);
}

FMI_Export fmiComponent fmiInstantiate(fmiString instanceName,
                                       fmiType   fmuType, 
                                       fmiString fmuGUID, 
                                       fmiString fmuResourceLocation, 
                                       const fmiCallbackFunctions* functions, 
                                       fmiBoolean                  visible,
                                       fmiBoolean                  loggingOn) {
                                           
    
    if (fmuType == fmiCoSimulation) {
#ifndef FMUCS20
        functions->logger(0, instanceName, fmiError, "ERROR", "The model is not compiled as a Co-Simulation FMU.");
        return NULL;
#endif
    } else if (fmuType == fmiModelExchange) {
#ifndef FMUME20
        functions->logger(0, instanceName, fmiError, "ERROR", "The model is not compiled as a Model Exchange FMU.");
        return NULL;
#endif
    }
    return fmi2_instantiate(instanceName, fmuType, fmuGUID, fmuResourceLocation,
                            functions, visible, loggingOn);
}

FMI_Export void fmiFreeInstance(fmiComponent c) {
    fmi2_free_instance(c);
}

FMI_Export fmiStatus fmiSetupExperiment(fmiComponent c, 
                                        fmiBoolean   toleranceDefined, 
                                        fmiReal      tolerance, 
                                        fmiReal      startTime, 
                                        fmiBoolean   stopTimeDefined, 
                                        fmiReal      stopTime) {
    return fmi2_setup_experiment(c, toleranceDefined, tolerance, startTime,
                                 stopTimeDefined, stopTime);
}

FMI_Export fmiStatus fmiEnterInitializationMode(fmiComponent c) {
    return fmi2_enter_initialization_mode(c);
}

FMI_Export fmiStatus fmiExitInitializationMode(fmiComponent c) {
    return fmi2_exit_initialization_mode(c);
}

FMI_Export fmiStatus fmiTerminate(fmiComponent c) {
    return fmi2_terminate(c);
}

FMI_Export fmiStatus fmiReset(fmiComponent c) {
    return fmi2_reset(c);
}

FMI_Export fmiStatus fmiGetReal(fmiComponent c, const fmiValueReference vr[],
                                size_t nvr, fmiReal value[]) {
    return fmi2_get_real(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiGetInteger(fmiComponent c, const fmiValueReference vr[],
                                   size_t nvr, fmiInteger value[]) {
    return fmi2_get_integer(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiGetBoolean(fmiComponent c, const fmiValueReference vr[],
                                   size_t nvr, fmiBoolean value[]) {
    return fmi2_get_boolean(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiGetString(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, fmiString value[]) {
    return fmi2_get_string(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiSetReal(fmiComponent c, const fmiValueReference vr[],
                                size_t nvr, const fmiReal value[]) {
    return fmi2_set_real(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiSetInteger(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, const fmiInteger value[]) {
    return fmi2_set_integer(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiSetBoolean(fmiComponent c, const fmiValueReference vr[],
                                   size_t nvr, const fmiBoolean value[]) {
    return fmi2_set_boolean(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiSetString(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, const fmiString value[]) {
    return fmi2_set_string(c, vr, nvr, value);
}

FMI_Export fmiStatus fmiGetFMUstate(fmiComponent c, fmiFMUstate* FMUstate) {
    return fmi2_get_fmu_state(c, FMUstate);
}

FMI_Export fmiStatus fmiSetFMUstate(fmiComponent c, fmiFMUstate FMUstate) {
    return fmi2_set_fmu_state(c, FMUstate);
}

FMI_Export fmiStatus fmiFreeFMUstate(fmiComponent c, fmiFMUstate* FMUstate) {
    return fmi2_free_fmu_state(c, FMUstate);
}

FMI_Export fmiStatus fmiSerializedFMUstateSize(fmiComponent c, fmiFMUstate FMUstate,
                                               size_t* size) {
    return fmi2_serialized_fmu_state_size(c, FMUstate, size);
}

FMI_Export fmiStatus fmiSerializedFMUstate(fmiComponent c, fmiFMUstate FMUstate,
                                  fmiByte serializedState[], size_t size) {
    return fmi2_serialized_fmu_state(c, FMUstate, serializedState, size);
}

FMI_Export fmiStatus fmiDeSerializedFMUstate(fmiComponent c,
                                  const fmiByte serializedState[],
                                  size_t size, fmiFMUstate* FMUstate) {
    return fmi2_de_serialized_fmu_state(c, serializedState, size, FMUstate);
}

FMI_Export fmiStatus fmiGetDirectionalDerivative(fmiComponent c,
                const fmiValueReference vUnknown_ref[], size_t nUnknown,
                const fmiValueReference vKnown_ref[],   size_t nKnown,
                const fmiReal dvKnown[], fmiReal dvUnknown[]) {
	return fmi2_get_directional_derivative(c, vUnknown_ref, nUnknown,
                                           vKnown_ref, nKnown, dvKnown, dvUnknown);
}
