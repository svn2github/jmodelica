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

#include <stdio.h>
#include "fmi_dll_1_0_cs.h"
#include "fmi_dll_1_0_me.h"
#include "fmi_dll_common.h"
#include "jm_types.h"


#define PRINT_MY_DEBUG printf("Line: %d \t File: %s \n",__LINE__, __FILE__)

void mylogger(fmiComponent c, fmiString instanceName, fmiStatus status, fmiString category, fmiString message, ...)
{
	char msg[2024];
	va_list argp;	
	va_start(argp, message);
	vsprintf(msg, message, argp);
	if (!instanceName) instanceName = "?";
	if (!category) category = "?";
	printf("fmiStatus = %d;  %s (%s): %s\n", status, instanceName, category, msg);
}

void do_pause()
{
#ifdef _MSC_VER
	system("PAUSE");
#elif
#endif
}

int main(int argc, char *argv[])
{
	
	fmi_dll_t* fmu;	
	const char* dllPath = "C:\\Documents and Settings\\p418_baa\\Desktop\\XMLtest\\temporaryfolder\\binaries\\win32\\Furuta.dll"; /* <-------- Must be set */
	const char* modelIdentifier = "Furuta"; /* <-------- Must be set */
	char* instanceName = "MyTestModel";
	char*  GUID = "f1542ab5f6c9378bdf2174aeb3a743b4"; /* <-------- Must be set */
	fmi_dll_standard_enu_t standard = 	FMI_ME1; /* or FMI_CS1 */	
	fmiBoolean loggingOn;
	fmiCallbackFunctions callBackFunctions;
	jm_status_enu_t status;
	size_t nstates = 4;		  /* <-------- Must be set */
	double* states = NULL;
	double* dstates = NULL;
	size_t nzerocrossing = 0; /* <-------- Must be set */
	double* zerocrossing = NULL;
	fmiBoolean callEventUpdate;
	int k;
	fmiBoolean toleranceControlled;
	fmiReal relativeTolerance;
	fmiEventInfo eventInfo;
	fmiBoolean intermediateResults;

	unsigned vr;
	unsigned* vrp;
	fmiString string;
	fmiBoolean boolean;
	fmiInteger integer;
	fmiReal real;

	callBackFunctions.logger = mylogger;
	callBackFunctions.allocateMemory = calloc;
	callBackFunctions.freeMemory = free;


	if (nstates > 0) {
		dstates = calloc(nstates, sizeof(double));
		states = calloc(nstates, sizeof(double));
		vrp = calloc(nstates, sizeof(unsigned));
	}

	if (nzerocrossing > 0) {
		zerocrossing = calloc(nzerocrossing, sizeof(double));
	}

	fmu = fmi_dll_common_create_dllfmu(dllPath, modelIdentifier, callBackFunctions, standard);
	if (fmu == NULL) {
		printf("An error occured while fmi_dll_common_create_dllfmu was called, an error message should been printed.\n");
		do_pause();
		return 0;
	}

	status = fmi_dll_common_load_dll(fmu);
	if (status == jm_status_error) {
		printf("Error in fmi_dll_common_load_dll: %s\n", fmi_dll_common_get_last_error(fmu));
		do_pause();
		return 0;
	}

	status = fmi_dll_common_load_fcn(fmu);
	if (status == jm_status_error) {
		printf("Error in fmi_dll_common_load_fcn: %s\n", fmi_dll_common_get_last_error(fmu));
		do_pause();
		return 0;
	}

	printf("fmi_dll_1_0_me_get_version:              %s\n", fmi_dll_1_0_me_get_version(fmu));
	printf("fmi_dll_1_0_me_get_model_types_platform: %s\n", fmi_dll_1_0_me_get_model_types_platform(fmu));

	loggingOn = fmiTrue;
	if (fmi_dll_1_0_me_instantiate_model(fmu, instanceName, GUID, loggingOn) == NULL) {		
		printf("fmi_dll_1_0_me_instantiate_model: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_instantiate_model: Success\n");
	}

	status = fmi_dll_1_0_me_set_time(fmu, 0.1);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_time: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_time: Success\n");
	}


	status = fmi_dll_1_0_me_set_continuous_states(fmu, states, nstates);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_continuous_states: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_continuous_states: Success\n");
		for (k=0; k < nstates; k++) {
			printf("\t x[%d] = %lf\n",k, states[k]);
		}
	}

	relativeTolerance = 1e-5;
	toleranceControlled = fmiTrue;
	status = fmi_dll_1_0_me_initialize(fmu, toleranceControlled, relativeTolerance, &eventInfo);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_initialize: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_initialize: Success\n");
		printf("\t fmiEventInfo.iterationConverged =          %s\n",  eventInfo.iterationConverged ?			"True" : "False");
		printf("\t fmiEventInfo.stateValueReferencesChanged = %s\n",  eventInfo.stateValueReferencesChanged ?	"True" : "False");
		printf("\t fmiEventInfo.stateValuesChanged =          %s\n",  eventInfo.stateValuesChanged ?			"True" : "False");
		printf("\t fmiEventInfo.terminateSimulation =         %s\n",  eventInfo.terminateSimulation ?			"True" : "False");
		printf("\t fmiEventInfo.upcomingTimeEvent =           %s\n",  eventInfo.upcomingTimeEvent ?				"True" : "False");
		printf("\t fmiEventInfo.nextEventTime =               %lf\n", eventInfo.nextEventTime);
	}	

	status = fmi_dll_1_0_me_completed_integrator_step(fmu, &callEventUpdate);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_completed_integrator_step: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_completed_integrator_step: Success\n");
		printf("\t callEventUpdate = %s\n", callEventUpdate ? "True" : "False");
	}

	status = fmi_dll_1_0_me_get_derivatives(fmu, dstates, nstates);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_derivatives: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_derivatives: Success\n");
		for (k=0; k < nstates; k++) {
			printf("\t dx[%d] = %lf\n",k, states[k]);
		}
	}


	status = fmi_dll_1_0_me_get_event_indicators(fmu, zerocrossing, nzerocrossing);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_event_indicators: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_event_indicators: Success\n");
		for (k=0; k < nzerocrossing; k++) {
			printf("\t nz[%d] = %lf\n",k, zerocrossing[k]);
		}
	}

	intermediateResults = fmiFalse;
	status = fmi_dll_1_0_me_eventUpdate(fmu, intermediateResults, &eventInfo);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_eventUpdate: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_eventUpdate: Success\n");
		printf("\t fmiEventInfo.iterationConverged =          %s\n",  eventInfo.iterationConverged ?			"True" : "False");
		printf("\t fmiEventInfo.stateValueReferencesChanged = %s\n",  eventInfo.stateValueReferencesChanged ?	"True" : "False");
		printf("\t fmiEventInfo.stateValuesChanged =          %s\n",  eventInfo.stateValuesChanged ?			"True" : "False");
		printf("\t fmiEventInfo.terminateSimulation =         %s\n",  eventInfo.terminateSimulation ?			"True" : "False");
		printf("\t fmiEventInfo.upcomingTimeEvent =           %s\n",  eventInfo.upcomingTimeEvent ?				"True" : "False");
		printf("\t fmiEventInfo.nextEventTime =               %lf\n", eventInfo.nextEventTime);
	}

	status = fmi_dll_1_0_me_get_continuous_states(fmu, states, nstates);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_continuous_states: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_continuous_states: Success\n");
		for (k=0; k < nstates; k++) {
			printf("\t x[%d] = %lf\n",k, states[k]);
		}
	}

	status = fmi_dll_1_0_me_get_nominal_continuous_states(fmu, states, nstates);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_nominal_continuous_states: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_nominal_continuous_states: Success\n");
		for (k=0; k < nstates; k++) {
			printf("\t x[%d] = %lf\n",k, states[k]);
		}
	}

	status = fmi_dll_1_0_me_get_state_value_references(fmu, vrp, nstates);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_state_value_references: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_state_value_references: Success\n");
		for (k=0; k < nstates; k++) {
			printf("\t vrp[%d] = %lf\n",k, vrp[k]);
		}
	}

	status = fmi_dll_1_0_me_set_debug_logging(fmu, fmiTrue);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_debug_logging: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_debug_logging: Success\n");
	}

/* Test fmiSetXXX */
/*
	vr = 0;
	string = "hej";
	status = fmi_dll_1_0_me_set_string(fmu, &vr, 1, &string);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_string: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_string: Success\n");
	}

	vr = 0;
	integer = 12;
	status = fmi_dll_1_0_me_set_integer(fmu, &vr, 1, &integer);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_integer: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_integer: Success\n");
	}

	vr = 0;
	boolean = 12;
	status = fmi_dll_1_0_me_set_boolean(fmu, &vr, 1, &boolean);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_boolean: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_boolean: Success\n");
	}

	vr = 0;
	real = 12;
	status = fmi_dll_1_0_me_set_real(fmu, &vr, 1, &real);	
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_set_real: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_set_real: Success\n");
	}
*/
/* Test fmiGetXXX */
/*
	vr = 0;
	status = fmi_dll_1_0_me_get_string(fmu, &vr, 1, &string);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_string: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_string: Success\n");
	}

	vr = 0;
	status = fmi_dll_1_0_me_get_integer(fmu, &vr, 1, &integer);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_integer: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_integer: Success\n");
	}

	vr = 0;
	status = fmi_dll_1_0_me_get_boolean(fmu, &vr, 1, &boolean);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_boolean: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_boolean: Success\n");
	}

	vr = 0;
	status = fmi_dll_1_0_me_get_real(fmu, &vr, 1, &real);	
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_get_real: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_get_real: Success\n");
	}
*/
	

	status = fmi_dll_1_0_me_terminate(fmu);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_me_terminate: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_me_terminate: Success\n");
	}

	fmi_dll_1_0_me_free_model_instance(fmu);
	printf("fmi_dll_1_0_me_instantiate_model: Success\n");		

	fmi_dll_common_free_dll(fmu);
	printf("fmi_dll_common_free_dll: Success\n");

	fmi_dll_common_destroy_dllfmu(fmu);
	printf("fmi_dll_common_destroy_dllfmu: Success\n");

	printf("Everything seems to be OK\n");

	do_pause();
}


