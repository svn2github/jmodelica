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
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <errno.h>

#include <jm_types.h>
#include <jm_portability.h>
#include <FMI1/fmi1_types.h>
#include <FMI1/fmi1_functions.h>
#include <FMI1/fmi1_capi.h>

#define PRINT_MY_DEBUG printf("Line: %d \t File: %s \n",__LINE__, __FILE__)

void mylogger(fmi1_component_t c, fmi1_string_t instanceName, fmi1_status_t status, fmi1_string_t category, fmi1_string_t message, ...)
{
	char msg[2024];
	va_list argp;	
	va_start(argp, message);
	vsprintf(msg, message, argp);
	if (!instanceName) instanceName = "?";
	if (!category) category = "?";
	printf("fmiStatus = %d;  %s (%s): %s\n", status, instanceName, category, msg);
}

void do_exit(int code)
{
	printf("Press any key to exit\n");
	getchar();
	exit(code);
}

int main(int argc, char *argv[])
{
	const char* dllPath = "C:\\Documents and Settings\\p418_baa\\Desktop\\XMLtest\\tempfolder\\binaries\\win32\\Furuta.dll"; /* <-------- Must be set */
	const char* modelIdentifier = "Furuta"; /* <-------- Must be set */
	char* instanceName = "MyTestModel";
	char*  GUID = "{1b4c7312-f193-4a2f-a06d-d59332c3c22d}"; /* <-------- Must be set */
	fmi1_fmu_kind_enu_t standard = fmi1_fmu_kind_enu_cs_standalone;
	fmi1_callback_functions_t callBackFunctions;
	jm_status_enu_t status;

	fmi1_capi_t* fmu;
	fmi1_string_t fmuLocation;
	fmi1_string_t mimeType;
	fmi1_real_t timeout;
	fmi1_boolean_t visible;
	fmi1_boolean_t interactive;
	fmi1_boolean_t loggingOn;

	fmi1_real_t tStart;
	fmi1_real_t tStop;
	fmi1_boolean_t StopTimeDefined;

	unsigned vr;
	unsigned* vrp;
	fmi1_string_t string;
	fmi1_boolean_t boolean;
	fmi1_integer_t integer;
	fmi1_real_t real;

	fmi1_real_t currentCommunicationPoint;
	fmi1_real_t communicationStepSize; 
	fmi1_boolean_t newStep;

	fmi1_status_kind_t statuskind;
	fmi1_status_t  statusvalue;


	callBackFunctions.logger = mylogger;
	callBackFunctions.allocateMemory = calloc;
	callBackFunctions.freeMemory = free;
	callBackFunctions.stepFinished = NULL;

	fmu = fmi1_capi_create_dllfmu(dllPath, modelIdentifier, callBackFunctions, standard);
	if (fmu == NULL) {
		printf("An error occured while fmi1_capi_create_dllfmu was called, an error message should been printed.\n");
		do_exit(1);
		return 0;
	}

	status = fmi1_capi_load_dll(fmu);
	if (status == jm_status_error) {
		printf("Error in fmi1_capi_load_dll: %s\n", fmi1_capi_get_last_error(fmu));
		do_exit(1);
		return 0;
	}

	status = fmi1_capi_load_fcn(fmu);
	if (status == jm_status_error) {
		printf("Error in fmi1_capi_load_fcn: %s\n", fmi1_capi_get_last_error(fmu));
		do_exit(1);
		return 0;
	}

	printf("fmi1_capi_get_version:        %s\n", fmi1_capi_get_version(fmu));
	printf("fmi1_capi_get_types_platform: %s\n", fmi1_capi_get_types_platform(fmu));


	
	fmuLocation = "";
	mimeType = "";
	timeout = 0;
	visible = fmi1_false;
	interactive = fmi1_false;
	loggingOn = fmi1_true;

	if (fmi1_capi_instantiate_slave(fmu, instanceName, GUID, fmuLocation, mimeType, timeout, visible, interactive, loggingOn) == NULL) {		
		printf("fmi1_capi_instantiate_slave: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_instantiate_slave: Success\n");
	}



	tStart = 0;
	tStop = 10;
	StopTimeDefined = fmi1_false;
	status = fmi1_capi_initialize_slave(fmu, tStart, StopTimeDefined, tStop);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_initialize_slave: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_initialize_slave: Success\n");
	}	

	status = fmi1_capi_set_debug_logging(fmu, fmi1_true);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_set_debug_logging: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_set_debug_logging: Success\n");
	}

/* Test fmiSetInputDerivative */
/*
	vr = 0;
	real = 0;
	integer = 1;
	status = fmi1_capi_set_real_input_derivatives(fmu, &vr, 1, &integer, &real);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_set_real_input_derivatives: Failed\n");
		system("PAUSE");
		return 0;
	} else {
		printf("fmi1_capi_set_real_input_derivatives: Success\n");
	}
*/

/* Test fmiGetOutputDerivative */
/*
	vr = 0;
	status = fmi1_capi_get_real_output_derivatives(fmu, &vr, 1, &integer, &real);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_real_output_derivatives: Failed\n");
		system("PAUSE");
		return 0;
	} else {
		printf("fmi1_capi_get_real_output_derivatives: Success\n");
	}
*/

/* Test fmiCancelStep */
/*
	status = fmi1_capi_cancel_step(fmu);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_cancel_step: Failed\n");
		system("PAUSE");
		return 0;
	} else {
		printf("fmi1_capi_cancel_step: Success\n");
	}	
*/

	currentCommunicationPoint = 0;
	communicationStepSize = 0.1;
	newStep = fmi1_true;
	status = fmi1_capi_do_step(fmu, currentCommunicationPoint, communicationStepSize, newStep);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_do_step: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_do_step: Success\n");
	}

	statuskind = fmi1_do_step_status;
	status = fmi1_capi_get_status(fmu, statuskind, &statusvalue);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_status: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_status: Success\n");
	}

	statuskind = fmi1_last_successful_time;
	status = fmi1_capi_get_real_status(fmu, statuskind, &real);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_real_status: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_real_status: Success\n");
	}

/*
	statuskind = fmiLastSuccessfulTime;
	status = fmi1_capi_get_integer_status(fmu, statuskind, &integer);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_integer_status: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_integer_status: Success\n");
	}
*/

/*
	statuskind = fmiLastSuccessfulTime;
	status = fmi1_capi_get_boolean_status(fmu, statuskind, &boolean);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_boolean_status: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_boolean_status: Success\n");
	}
*/

/*
	statuskind = fmiLastSuccessfulTime;
	status = fmi1_capi_get_string_status(fmu, statuskind, &string);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_string_status: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_string_status: Success\n");
	}
*/

/* Test fmiSetXXX */
/*
	vr = 0;
	string = "hej";
	status = fmi1_capi_set_string(fmu, &vr, 1, &string);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_set_string: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_set_string: Success\n");
	}

	vr = 0;
	integer = 12;
	status = fmi1_capi_set_Integer(fmu, &vr, 1, &integer);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_set_Integer: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_set_Integer: Success\n");
	}

	vr = 0;
	boolean = 12;
	status = fmi1_capi_set_boolean(fmu, &vr, 1, &boolean);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_set_boolean: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_set_boolean: Success\n");
	}

	vr = 0;
	real = 12;
	status = fmi1_capi_set_real(fmu, &vr, 1, &real);	
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_set_real: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_set_real: Success\n");
	}
*/
/* Test fmiGetXXX */
/*
	vr = 0;
	status = fmi1_capi_get_string(fmu, &vr, 1, &string);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_string: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_string: Success\n");
	}

	vr = 0;
	status = fmi1_capi_get_integer(fmu, &vr, 1, &integer);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_integer: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_integer: Success\n");
	}

	vr = 0;
	status = fmi1_capi_get_boolean(fmu, &vr, 1, &boolean);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_boolean: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_boolean: Success\n");
	}

	vr = 0;
	status = fmi1_capi_get_real(fmu, &vr, 1, &real);	
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_get_real: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_get_real: Success\n");
	}
*/
	

/*
	status = fmi1_capi_reset_slave(fmu);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_reset_slave: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_reset_slave: Success\n");
	}
*/

	status = fmi1_capi_terminate_slave(fmu);
	if (status == fmi1_status_error || status == fmi1_status_fatal) {
		printf("fmi1_capi_terminate_slave: Failed\n");
		do_exit(1);
		return 0;
	} else {
		printf("fmi1_capi_terminate_slave: Success\n");
	}

	fmi1_capi_free_slave_instance(fmu);
	printf("fmi1_capi_free_slave_instance: Success\n");		

	fmi1_capi_free_dll(fmu);
	printf("fmi1_capi_free_dll: Success\n");

	fmi1_capi_destroy_dllfmu(fmu);
	printf("fmi1_capi_destroy_dllfmu: Success\n");

	printf("Everything seems to be OK\n");

	do_exit(1);
}


