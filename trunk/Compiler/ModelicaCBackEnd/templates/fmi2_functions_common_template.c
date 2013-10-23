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

DllExport const char* fmiGetTypesPlatform() {
    return fmi2_get_types_platform();
}

DllExport const char* fmiGetVersion() {
    return fmi2_get_version();
}

DllExport fmiStatus fmiSetDebugLogging(fmiComponent    c,
                                       fmiBoolean      loggingOn, 
                                       size_t          nCategories, 
                                       const fmiString categories[])) {
    return fmi2_set_debug_logging(c, loggingOn, nCategories, categories);
}

DllExport fmiComponent fmiInstantiate(fmiString instanceName,
                                      fmiType   fmuType, 
                                      fmiString fmuGUID, 
                                      fmiString fmuResourceLocation, 
                                      const fmiCallbackFunctions* functions, 
                                      fmiBoolean                  visible,
                                      fmiBoolean                  loggingOn) {
    return fmi2_instatiate(instanceName, fmuType, fmuGUID, fmuResourceLocation,
                           functions, visible, loggingOn);
}

DllExport void fmiFreeInstance(fmiComponent c) {
    fmi2_free_instance(c);
}

DllExport fmiStatus fmiSetupExperiment(fmiComponent c, 
                                       fmiBoolean   toleranceDefined, 
                                       fmiReal      tolerance, 
                                       fmiReal      startTime, 
                                       fmiBoolean   stopTimeDefined, 
                                       fmiReal      stopTime) {
    return fmi2_setup_experiment(c, toleranceDefined, tolerance, startTime,
                                 stopTimeDefined, stopTime);
}

DllExport fmiStatus fmiEnterInitializationMode(fmiComponent c) {
    return fmi2_enter_initialization_mode(c);
}

DllExport fmiStatus fmiExitInitializationMode(fmiComponent c) {
    return fmi2_exit_initialization_mode(c);
}

DllExport fmiStatus fmiTerminate(fmiComponent c) {
    return fmi2_terminate(c);
}

DllExport fmiStatus fmiReset(fmiComponent c) {
    return fmi2_reset(c);
}

DllExport fmiStatus fmiGetReal(fmiComponent c, const fmiValueReference vr[],
                               size_t nvr, fmiReal value[]) {
    return fmi2_get_real(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetInteger(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, fmiInteger value[]) {
    return fmi2_get_integer(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetBoolean(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, fmiBoolean value[]) {
    return fmi2_get_boolean(c, vr, nvr, value);
}

DllExport fmiStatus fmiGetString(fmiComponent c, const fmiValueReference vr[],
                                 size_t nvr, fmiString value[]) {
    return fmi2_get_string(c, vr, nvr, value);
}

DllExport fmiStatus fmiSetReal(fmiComponent c, const fmiValueReference vr[],
                               size_t nvr, const fmiReal value[]) {
    return fmi2_set_real(c, vr, nvrm value);
}

DllExport fmiStatus fmiSetInteger(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, const fmiInteger value[]) {
    return fmi2_set_integer(c, vr, nvrm value);
}

DllExport fmiStatus fmiSetBoolean(fmiComponent c, const fmiValueReference vr[],
                                  size_t nvr, const fmiBoolean value[]) {
    return fmi2_set_boolean(c, vr, nvrm value);
}

DllExport fmiStatus fmiSetString(fmiComponent c, const fmiValueReference vr[],
                                 size_t nvr, const fmiString value[]) {
    return fmi2_set_string(c, vr, nvrm value);
}

DllExport fmiStatus fmiGetFMUstate(fmiComponent c, fmiFMUstate* FMUstate) {
    return fmi2_get_fmu_state(c, FMUstate);
}

DllExport fmiStatus fmiSetFMUstate(fmiComponent c, fmiFMUstate FMUstate) {
    return fmi2_set_fmu_state(c, FMUstate);
}

DllExport fmiStatus fmiFreeFMUstate(fmiComponent c, fmiFMUstate* FMUstate) {
    return fmi2_free_fmu_state(c, FMUstate);
}

DllExport fmiStatus fmiSerializedFMUstateSize(fmiComponent c, fmiFMUstate FMUstate,
                                    size_t* size) {
    return fmi2_serialized_fmu_state_size(c, FMUstate, size);
}

DllExport fmiStatus fmiSerializedFMUstate(fmiComponent c, fmiFMUstate FMUstate,
                                fmiByte serializedState[], size_t size) {
    return fmi2_serialized_fmu_state(c, FMUstate, serializedState, size);
}

DllExprot fmiStatus fmiDeSerializedFMUstate(fmiComponent c,
                                  const fmiByte serializedState[],
                                  size_t size, fmiFMUstate* FMUstate) {
    return fmi2_de_serialized_fmu_state(c, serializedState, size, FMUstate);
}

DllExport fmiStatus fmiGetDirectionalDerivative(fmiComponent c,
                const fmiValueReference vUnknown_ref[], size_t nUnknown,
                const fmiValueReference vKnown_ref[],   size_t nKnown,
                const fmiReal dvKnown[], fmiReal dvUnknown[]) {
	return fmi2_get_directional_derivative(c, vUnknown_ref, nUnknown,
                                           vKnown_ref, nKnown, dvKnown, dvUnknown);
}
