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


#ifndef FMI1_CAPI_H_
#define FMI1_CAPI_H_

#include <FMI1/fmi1_types.h>
#include <FMI1/fmi1_functions.h>
#include <FMI1/fmi1_enums.h>
#include <jm_portability.h>

typedef struct { /* FMI1 CAPI struct */
	const char* dllPath;						/* Full path to the DLL file */
	const char* modelIdentifier;				/* Used to get the FMI fuctions */	
	fmi1_callback_functions_t callBackFunctions;		/* Callback function structure passed to the model instantiated */

	#define FMI_MAX_ERROR_MESSAGE_SIZE 1000

    char errMessageBuf[FMI_MAX_ERROR_MESSAGE_SIZE];

        DLL_HANDLE dllHandle;

	fmi1_fmu_kind_enu_t standard;

	fmi1_component_t					c;

	/* FMI common */
	fmi1_get_version_ft				fmiGetVersion;
	fmi1_set_debug_logging_ft			fmiSetDebugLogging;
    fmi1_set_real_ft					fmiSetReal;
    fmi1_set_integer_ft				fmiSetInteger;
    fmi1_set_boolean_ft				fmiSetBoolean;
    fmi1_set_string_ft					fmiSetString;
	fmi1_get_real_ft					fmiGetReal;
    fmi1_get_integer_ft				fmiGetInteger;
    fmi1_get_boolean_ft				fmiGetBoolean;
    fmi1_get_string_ft					fmiGetString;

	/* FMI ME */
    fmi1_get_model_typesPlatform_ft		fmiGetModelTypesPlatform;    
    fmi1_instantiate_model_ft			fmiInstantiateModel;
    fmi1_free_model_instance_ft			fmiFreeModelInstance;    
    fmi1_set_time_ft					fmiSetTime;
    fmi1_set_continuous_states_ft		fmiSetContinuousStates;
    fmi1_completed_integrator_step_ft	fmiCompletedIntegratorStep;
    fmi1_initialize_ft			 	fmiInitialize;
    fmi1_get_derivatives_ft			fmiGetDerivatives;
    fmi1_get_event_indicators_ft		fmiGetEventIndicators;
    fmi1_event_update_ft				fmiEventUpdate;
    fmi1_get_continuous_states_ft		fmiGetContinuousStates;
    fmi1_get_nominal_continuousStates_ft fmiGetNominalContinuousStates;
    fmi1_get_state_valueReferences_ft	fmiGetStateValueReferences;
    fmi1_terminate_ft					fmiTerminate;

	/* FMI CS */
	fmi1_get_types_platform_ft			fmiGetTypesPlatform;   
    fmi1_instantiate_slave_ft			fmiInstantiateSlave;
    fmi1_initialize_slave_ft			fmiInitializeSlave;
    fmi1_terminate_slave_ft			fmiTerminateSlave;
    fmi1_reset_slave_ft				fmiResetSlave;
    fmi1_free_slave_instance_ft			fmiFreeSlaveInstance;
    fmi1_set_real_inputDerivatives_ft	fmiSetRealInputDerivatives;
    fmi1_get_real_outputDerivatives_ft	fmiGetRealOutputDerivatives;
    fmi1_do_step_ft					fmiDoStep;
    fmi1_cancel_step_ft				fmiCancelStep;
    fmi1_get_status_ft					fmiGetStatus;
    fmi1_get_real_status_ft				fmiGetRealStatus;
    fmi1_get_integer_status_ft			fmiGetIntegerStatus;
    fmi1_get_boolean_status_ft			fmiGetBooleanStatus;
    fmi1_get_string_status_ft			fmiGetStringStatus;

} fmi1_capi_t;

/* Help function used in the instantiate functions */
const char*		fmi1_capi_get_last_error(fmi1_capi_t* fmu);
void			fmi1_capi_destroy_dllfmu(fmi1_capi_t* fmu);
fmi1_capi_t*	fmi1_capi_create_dllfmu(const char* dllPath, const char* modelIdentifier, fmi1_callback_functions_t callBackFunctions, fmi1_fmu_kind_enu_t standard);
jm_status_enu_t fmi1_capi_load_fcn(fmi1_capi_t* fmu);
jm_status_enu_t fmi1_capi_load_dll(fmi1_capi_t* fmu);
jm_status_enu_t fmi1_capi_free_dll(fmi1_capi_t* fmu);

/* FMI 1.0 Common functions */
const char*			fmi1_capi_get_version						(fmi1_capi_t* fmu);
fmi1_status_t		fmi1_capi_set_debug_logging					(fmi1_capi_t* fmu, fmi1_boolean_t loggingOn);
fmi1_status_t		fmi1_capi_set_real							(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_real_t    value[]);
fmi1_status_t		fmi1_capi_set_Integer						(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t value[]);
fmi1_status_t		fmi1_capi_set_boolean						(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_boolean_t value[]);
fmi1_status_t		fmi1_capi_set_string						(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_string_t  value[]);
fmi1_status_t		fmi1_capi_get_real							(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_real_t    value[]);
fmi1_status_t		fmi1_capi_get_integer						(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_integer_t value[]);
fmi1_status_t		fmi1_capi_get_boolean						(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_boolean_t value[]);
fmi1_status_t		fmi1_capi_get_string						(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, fmi1_string_t  value[]);


/* FMI 1.0 ME functions */
const char*			fmi1_capi_get_model_types_platform			(fmi1_capi_t* fmu);
fmi1_component_t		fmi1_capi_instantiate_model					(fmi1_capi_t* fmu, fmi1_string_t instanceName, fmi1_string_t GUID, fmi1_boolean_t loggingOn);
void				fmi1_capi_free_model_instance				(fmi1_capi_t* fmu);
fmi1_status_t		fmi1_capi_set_time							(fmi1_capi_t* fmu, fmi1_real_t time);
fmi1_status_t		fmi1_capi_set_continuous_states				(fmi1_capi_t* fmu, const fmi1_real_t x[], size_t nx);
fmi1_status_t		fmi1_capi_completed_integrator_step			(fmi1_capi_t* fmu, fmi1_boolean_t* callEventUpdate);
fmi1_status_t		fmi1_capi_initialize						(fmi1_capi_t* fmu, fmi1_boolean_t toleranceControlled, fmi1_real_t relativeTolerance, fmi1_event_info_t* eventInfo);
fmi1_status_t		fmi1_capi_get_derivatives					(fmi1_capi_t* fmu, fmi1_real_t derivatives[]    , size_t nx);
fmi1_status_t		fmi1_capi_get_event_indicators				(fmi1_capi_t* fmu, fmi1_real_t eventIndicators[], size_t ni);
fmi1_status_t		fmi1_capi_eventUpdate						(fmi1_capi_t* fmu, fmi1_boolean_t intermediateResults, fmi1_event_info_t* eventInfo);
fmi1_status_t		fmi1_capi_get_continuous_states				(fmi1_capi_t* fmu, fmi1_real_t states[], size_t nx);
fmi1_status_t		fmi1_capi_get_nominal_continuous_states		(fmi1_capi_t* fmu, fmi1_real_t x_nominal[], size_t nx);
fmi1_status_t		fmi1_capi_get_state_value_references		(fmi1_capi_t* fmu, fmi1_value_reference_t vrx[], size_t nx);
fmi1_status_t		fmi1_capi_terminate							(fmi1_capi_t* fmu);

/* FMI 1.0 CS functions */
const char*			fmi1_capi_get_types_platform				(fmi1_capi_t* fmu);
fmi1_component_t		fmi1_capi_instantiate_slave					(fmi1_capi_t* fmu, fmi1_string_t instanceName, fmi1_string_t fmuGUID, fmi1_string_t fmuLocation, fmi1_string_t mimeType,
																 fmi1_real_t timeout, fmi1_boolean_t visible, fmi1_boolean_t interactive, fmi1_boolean_t loggingOn);
fmi1_status_t		fmi1_capi_initialize_slave					(fmi1_capi_t* fmu, fmi1_real_t tStart, fmi1_boolean_t StopTimeDefined, fmi1_real_t tStop);
fmi1_status_t		fmi1_capi_terminate_slave					(fmi1_capi_t* fmu);
fmi1_status_t		fmi1_capi_reset_slave						(fmi1_capi_t* fmu);
void				fmi1_capi_free_slave_instance				(fmi1_capi_t* fmu);
fmi1_status_t		fmi1_capi_set_real_input_derivatives		(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t order[], const  fmi1_real_t value[]);                                                  
fmi1_status_t		fmi1_capi_get_real_output_derivatives		(fmi1_capi_t* fmu, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t order[], fmi1_real_t value[]);                                              
fmi1_status_t		fmi1_capi_cancel_step						(fmi1_capi_t* fmu);
fmi1_status_t		fmi1_capi_do_step							(fmi1_capi_t* fmu, fmi1_real_t currentCommunicationPoint, fmi1_real_t communicationStepSize, fmi1_boolean_t newStep);
fmi1_status_t		fmi1_capi_get_status						(fmi1_capi_t* fmu, const fmi1_status_kind_t s, fmi1_status_t*  value);
fmi1_status_t		fmi1_capi_get_real_status					(fmi1_capi_t* fmu, const fmi1_status_kind_t s, fmi1_real_t*    value);
fmi1_status_t		fmi1_capi_get_integer_status				(fmi1_capi_t* fmu, const fmi1_status_kind_t s, fmi1_integer_t* value);
fmi1_status_t		fmi1_capi_get_boolean_status				(fmi1_capi_t* fmu, const fmi1_status_kind_t s, fmi1_boolean_t* value);
fmi1_status_t		fmi1_capi_get_string_status					(fmi1_capi_t* fmu, const fmi1_status_kind_t s, fmi1_string_t*  value);

#endif /* End of header file FMI1_CAPI_H_ */
