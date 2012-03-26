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

#ifndef FMI1_FUNCTIONS_H_
#define FMI1_FUNCTIONS_H_

#include "fmi1_types.h"
#include <string.h>

/* Type definitions */
typedef enum {
	fmi1_status_ok,
	fmi1_status_warning,
	fmi1_status_discard,
	fmi1_status_error,
	fmi1_status_fatal,
	fmi1_status_pending
} fmi1_status_t;

const char* fmi1_status_to_string(fmi1_status_t status);

typedef void  (*fmi1_callback_logger_ft)        (fmi1_component_t c, fmi1_string_t instanceName, fmi1_status_t status, fmi1_string_t category, fmi1_string_t message, ...);
typedef void* (*fmi1_callback_allocate_memory_ft)(size_t nobj, size_t size);
typedef void  (*fmi1_callback_free_memory_ft)    (void* obj);
typedef void  (*fmi1_step_finished_ft)          (fmi1_component_t c, fmi1_status_t status);

typedef struct {
	fmi1_callback_logger_ft         logger;
	fmi1_callback_allocate_memory_ft allocateMemory;
	fmi1_callback_free_memory_ft     freeMemory;
	fmi1_step_finished_ft           stepFinished;
} fmi1_callback_functions_t;

typedef struct {
	fmi1_boolean_t iterationConverged;
	fmi1_boolean_t stateValueReferencesChanged;
	fmi1_boolean_t stateValuesChanged;
	fmi1_boolean_t terminateSimulation;
	fmi1_boolean_t upcomingTimeEvent;
	fmi1_real_t    nextEventTime;
} fmi1_event_info_t;

typedef enum {
	fmi1_do_step_status,
	fmi1_pending_status,
	fmi1_last_successful_time
} fmi1_status_kind_t;

/* FMI 1.0 common functions */
typedef const char*	  	    (*fmi1_get_version_ft)					();
typedef fmi1_status_t		(*fmi1_set_debug_logging_ft)			(fmi1_component_t c, fmi1_boolean_t loggingOn);
typedef fmi1_status_t		(*fmi1_set_real_ft)						(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_real_t   value[]);
typedef fmi1_status_t		(*fmi1_set_integer_ft)					(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t value[]);
typedef fmi1_status_t		(*fmi1_set_boolean_ft)					(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_boolean_t value[]);
typedef fmi1_status_t		(*fmi1_set_string_ft)					(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, const fmi1_string_t  value[]);
typedef fmi1_status_t		(*fmi1_get_real_ft)						(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, fmi1_real_t   value[]);
typedef fmi1_status_t		(*fmi1_get_integer_ft)					(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, fmi1_integer_t value[]);
typedef fmi1_status_t		(*fmi1_get_boolean_ft)					(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, fmi1_boolean_t value[]);
typedef fmi1_status_t		(*fmi1_get_string_ft)					(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t nvr, fmi1_string_t  value[]);

/* FMI ME 1.0 functions */
typedef const char*		    (*fmi1_get_model_typesPlatform_ft)		();
typedef fmi1_component_t	(*fmi1_instantiate_model_ft)			(fmi1_string_t instanceName, fmi1_string_t GUID, fmi1_callback_functions_t functions, fmi1_boolean_t loggingOn);
typedef void			    (*fmi1_free_model_instance_ft)			(fmi1_component_t c);
typedef fmi1_status_t		(*fmi1_set_time_ft)					(fmi1_component_t c, fmi1_real_t time);
typedef fmi1_status_t		(*fmi1_set_continuous_states_ft)		(fmi1_component_t c, const fmi1_real_t x[], size_t nx);
typedef fmi1_status_t		(*fmi1_completed_integrator_step_ft)	(fmi1_component_t c, fmi1_boolean_t* callEventUpdate);
typedef fmi1_status_t		(*fmi1_initialize_ft)					(fmi1_component_t c, fmi1_boolean_t toleranceControlled, fmi1_real_t relativeTolerance, fmi1_event_info_t* eventInfo);
typedef fmi1_status_t		(*fmi1_get_derivatives_ft)				(fmi1_component_t c, fmi1_real_t derivatives[]    , size_t nx);
typedef fmi1_status_t		(*fmi1_get_event_indicators_ft)			(fmi1_component_t c, fmi1_real_t eventIndicators[], size_t ni);
typedef fmi1_status_t		(*fmi1_event_update_ft)				(fmi1_component_t c, fmi1_boolean_t intermediateResults, fmi1_event_info_t* eventInfo);
typedef fmi1_status_t		(*fmi1_get_continuous_states_ft)		(fmi1_component_t c, fmi1_real_t states[], size_t nx);
typedef fmi1_status_t		(*fmi1_get_nominal_continuousStates_ft)	(fmi1_component_t c, fmi1_real_t x_nominal[], size_t nx);
typedef fmi1_status_t		(*fmi1_get_state_valueReferences_ft)	(fmi1_component_t c, fmi1_value_reference_t vrx[], size_t nx);
typedef fmi1_status_t		(*fmi1_terminate_ft)					(fmi1_component_t c);  


/* FMI CS 1.0 functions */
typedef const char*		(*fmi1_get_types_platform_ft)			();
typedef fmi1_component_t	(*fmi1_instantiate_slave_ft)			(fmi1_string_t  instanceName, fmi1_string_t  fmuGUID, fmi1_string_t  fmuLocation, 
															 fmi1_string_t  mimeType, fmi1_real_t timeout, fmi1_boolean_t visible, fmi1_boolean_t interactive, 
															 fmi1_callback_functions_t functions, fmi1_boolean_t loggingOn);
typedef fmi1_status_t		(*fmi1_initialize_slave_ft)			(fmi1_component_t c, fmi1_real_t tStart, fmi1_boolean_t StopTimeDefined, fmi1_real_t tStop);
typedef fmi1_status_t		(*fmi1_terminate_slave_ft)				(fmi1_component_t c);
typedef fmi1_status_t		(*fmi1_reset_slave_ft)					(fmi1_component_t c);
typedef void			    (*fmi1_free_slave_instance_ft)			(fmi1_component_t c);
typedef fmi1_status_t		(*fmi1_set_real_inputDerivatives_ft)	(fmi1_component_t c, const  fmi1_value_reference_t vr[], size_t nvr, const fmi1_integer_t order[], const  fmi1_real_t value[]);                                                  
typedef fmi1_status_t		(*fmi1_get_real_outputDerivatives_ft)	(fmi1_component_t c, const fmi1_value_reference_t vr[], size_t  nvr, const fmi1_integer_t order[], fmi1_real_t value[]);                                              
typedef fmi1_status_t		(*fmi1_cancel_step_ft)					(fmi1_component_t c);
typedef fmi1_status_t		(*fmi1_do_step_ft)						(fmi1_component_t c, fmi1_real_t currentCommunicationPoint, fmi1_real_t communicationStepSize, fmi1_boolean_t newStep);

typedef fmi1_status_t		(*fmi1_get_status_ft)					(fmi1_component_t c, const fmi1_status_kind_t s, fmi1_status_t*  value);
typedef fmi1_status_t		(*fmi1_get_real_status_ft)				(fmi1_component_t c, const fmi1_status_kind_t s, fmi1_real_t*    value);
typedef fmi1_status_t		(*fmi1_get_integer_status_ft)			(fmi1_component_t c, const fmi1_status_kind_t s, fmi1_integer_t* value);
typedef fmi1_status_t		(*fmi1_get_boolean_status_ft)			(fmi1_component_t c, const fmi1_status_kind_t s, fmi1_boolean_t* value);
typedef fmi1_status_t		(*fmi1_get_string_status_ft)			(fmi1_component_t c, const fmi1_status_kind_t s, fmi1_string_t*  value); 

#endif /* End of header file FMI_FUNCTIONS_H_ */
