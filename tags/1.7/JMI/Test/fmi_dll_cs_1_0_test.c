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
	const char* dllPath = "C:\\Documents and Settings\\p418_baa\\Desktop\\XMLtest\\tempfolder\\binaries\\win32\\Furuta.dll"; /* <-------- Must be set */
	const char* modelIdentifier = "Furuta"; /* <-------- Must be set */
	char* instanceName = "MyTestModel";
	char*  GUID = "{1b4c7312-f193-4a2f-a06d-d59332c3c22d}"; /* <-------- Must be set */
	fmi_dll_standard_enu_t standard = FMI_CS1;	
	fmiCallbackFunctions callBackFunctions;
	jm_status_enu_t status;

	fmiString fmuLocation;
	fmiString mimeType;
	fmiReal timeout;
	fmiBoolean visible;
	fmiBoolean interactive;
	fmiBoolean loggingOn;

	fmiReal tStart;
	fmiReal tStop;
	fmiBoolean StopTimeDefined;

	unsigned vr;
	unsigned* vrp;
	fmiString string;
	fmiBoolean boolean;
	fmiInteger integer;
	fmiReal real;

	fmiReal currentCommunicationPoint;
	fmiReal communicationStepSize; 
	fmiBoolean newStep;

	fmiStatusKind statuskind;
	fmiStatus  statusvalue;


	callBackFunctions.logger = mylogger;
	callBackFunctions.allocateMemory = calloc;
	callBackFunctions.freeMemory = free;
	callBackFunctions.stepFinished = NULL;

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

	printf("fmi_dll_1_0_cs_get_version:        %s\n", fmi_dll_1_0_cs_get_version(fmu));
	printf("fmi_dll_1_0_cs_get_types_platform: %s\n", fmi_dll_1_0_cs_get_types_platform(fmu));


	
	fmuLocation = "";
	mimeType = "";
	timeout = 0;
	visible = fmiFalse;
	interactive = fmiFalse;
	loggingOn = fmiTrue;

	if (fmi_dll_1_0_cs_instantiate_slave(fmu, instanceName, GUID, fmuLocation, mimeType, timeout, visible, interactive, loggingOn) == NULL) {		
		printf("fmi_dll_1_0_cs_instantiate_slave: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_instantiate_slave: Success\n");
	}



	tStart = 0;
	tStop = 10;
	StopTimeDefined = fmiFalse;
	status = fmi_dll_1_0_cs_initialize_slave(fmu, tStart, StopTimeDefined, tStop);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_initialize_slave: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_initialize_slave: Success\n");
	}	

	status = fmi_dll_1_0_cs_set_debug_logging(fmu, fmiTrue);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_set_debug_logging: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_set_debug_logging: Success\n");
	}

/* Test fmiSetInputDerivative */
/*
	vr = 0;
	real = 0;
	integer = 1;
	status = fmi_dll_1_0_cs_set_real_input_derivatives(fmu, &vr, 1, &integer, &real);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_set_real_input_derivatives: Failed\n");
		system("PAUSE");
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_set_real_input_derivatives: Success\n");
	}
*/

/* Test fmiGetOutputDerivative */
/*
	vr = 0;
	status = fmi_dll_1_0_cs_get_real_output_derivatives(fmu, &vr, 1, &integer, &real);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_real_output_derivatives: Failed\n");
		system("PAUSE");
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_real_output_derivatives: Success\n");
	}
*/

/* Test fmiCancelStep */
/*
	status = fmi_dll_1_0_cs_cancel_step(fmu);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_cancel_step: Failed\n");
		system("PAUSE");
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_cancel_step: Success\n");
	}	
*/

	currentCommunicationPoint = 0;
	communicationStepSize = 0.1;
	newStep = fmiTrue;
	status = fmi_dll_1_0_cs_do_step(fmu, currentCommunicationPoint, communicationStepSize, newStep);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_do_step: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_do_step: Success\n");
	}

	statuskind = fmiDoStepStatus;
	status = fmi_dll_1_0_cs_get_status(fmu, statuskind, &statusvalue);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_status: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_status: Success\n");
	}

	statuskind = fmiLastSuccessfulTime;
	status = fmi_dll_1_0_cs_get_real_status(fmu, statuskind, &real);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_real_status: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_real_status: Success\n");
	}

/*
	statuskind = fmiLastSuccessfulTime;
	status = fmi_dll_1_0_cs_get_integer_status(fmu, statuskind, &integer);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_integer_status: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_integer_status: Success\n");
	}
*/

/*
	statuskind = fmiLastSuccessfulTime;
	status = fmi_dll_1_0_cs_get_boolean_status(fmu, statuskind, &boolean);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_boolean_status: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_boolean_status: Success\n");
	}
*/

/*
	statuskind = fmiLastSuccessfulTime;
	status = fmi_dll_1_0_cs_get_string_status(fmu, statuskind, &string);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_string_status: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_string_status: Success\n");
	}
*/

/* Test fmiSetXXX */
/*
	vr = 0;
	string = "hej";
	status = fmi_dll_1_0_cs_set_string(fmu, &vr, 1, &string);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_set_string: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_set_string: Success\n");
	}

	vr = 0;
	integer = 12;
	status = fmi_dll_1_0_cs_set_Integer(fmu, &vr, 1, &integer);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_set_Integer: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_set_Integer: Success\n");
	}

	vr = 0;
	boolean = 12;
	status = fmi_dll_1_0_cs_set_boolean(fmu, &vr, 1, &boolean);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_set_boolean: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_set_boolean: Success\n");
	}

	vr = 0;
	real = 12;
	status = fmi_dll_1_0_cs_set_real(fmu, &vr, 1, &real);	
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_set_real: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_set_real: Success\n");
	}
*/
/* Test fmiGetXXX */
/*
	vr = 0;
	status = fmi_dll_1_0_cs_get_string(fmu, &vr, 1, &string);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_string: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_string: Success\n");
	}

	vr = 0;
	status = fmi_dll_1_0_cs_get_integer(fmu, &vr, 1, &integer);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_integer: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_integer: Success\n");
	}

	vr = 0;
	status = fmi_dll_1_0_cs_get_boolean(fmu, &vr, 1, &boolean);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_boolean: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_boolean: Success\n");
	}

	vr = 0;
	status = fmi_dll_1_0_cs_get_real(fmu, &vr, 1, &real);	
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_get_real: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_get_real: Success\n");
	}
*/
	

/*
	status = fmi_dll_1_0_cs_reset_slave(fmu);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_reset_slave: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_reset_slave: Success\n");
	}
*/

	status = fmi_dll_1_0_cs_terminate_slave(fmu);
	if (status == fmiError || status == fmiFatal) {
		printf("fmi_dll_1_0_cs_terminate_slave: Failed\n");
		do_pause();
		return 0;
	} else {
		printf("fmi_dll_1_0_cs_terminate_slave: Success\n");
	}

	fmi_dll_1_0_cs_free_slave_instance(fmu);
	printf("fmi_dll_1_0_cs_free_slave_instance: Success\n");		

	fmi_dll_common_free_dll(fmu);
	printf("fmi_dll_common_free_dll: Success\n");

	fmi_dll_common_destroy_dllfmu(fmu);
	printf("fmi_dll_common_destroy_dllfmu: Success\n");

	printf("Everything seems to be OK\n");

	do_pause();
}


