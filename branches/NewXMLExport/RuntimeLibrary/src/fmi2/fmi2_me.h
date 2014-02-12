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

#ifndef fmi2_me_h
#define fmi2_me_h

#include "fmiFunctions.h"
#include "jmi_util.h"
#include "jmi.h"
#include "jmi_me.h"

/** \file fmi2_me.h
 *  \brief The public FMI 2.0 model interface.
 **/

/* @{ */

/* Type definitions */
/* typedef */

typedef enum {
    initializationMode,
    eventMode,
    continuousTimeMode,
    instantiatedMode,
	slaveInitialized,
	terminated
} fmi_mode_t;

typedef struct fmi2_me_t fmi2_me_t;  /**< \brief Forward declaration of struct. */

struct fmi2_me_t {
    jmi_t jmi;                  /* should be the first one so that jmi* and fmi1_me* point at the same address */
    fmi_mode_t fmi_mode;
    fmiType fmu_type;
    fmiString fmi_instance_name;
    fmiEventInfo event_info;
    const fmiCallbackFunctions* fmi_functions;
};

/**
 * \defgroup The shared public functions for FMI 2.0.
 * 
 * \brief Definitions of the shared functions for Model Exchange and Co-Simulation.
 */
 
 /* @{ */

/**
 * \brief Returns the platform types compiled for.
 *
 * This methods returns the string to uniquely identify the "fmiTypesPlatform.h"
 * header file for which the FMU was compiled for.
 * 
 * @return The identifier of platform types compiled for.
 */
const char* fmi2_get_types_platform();

/**
 * \brief Returns the FMI version of the header file.
 * 
 * @return The FMI version of fmiFunctions.h.
 */
const char* fmi2_get_version();

/**
 * \brief Sets the logging settings.
 * 
 * @param c The FMU struct.
 * @param loggingOn A fmiBoolean, sets logging on or off.
 * @param nCategories Number of categories.
 * @param categories The categories to be logging for.
 * @return Error code.
 */
fmiStatus fmi2_set_debug_logging(fmiComponent    c,
                                 fmiBoolean      loggingOn, 
                                 size_t          nCategories, 
                                 const fmiString categories[]);

/**
 * \brief Instantiates the FMU.
 * 
 * @param instanceName The name of the instance.
 * @param fmuType The fmi type to instanciate.
 * @param GUID The GUID identifier.
 * @param fmuResourceLocation The location of the resource directory.
 * @param functions Callback functions for logging, allocation and deallocation.
 * @param visible A fmiBoolean, defines the amount of interaction with the user.
 * @param loggingOn Turn of or on logging, fmiBoolean.
 * @return An instance of a model.
 */
fmiComponent fmi2_instantiate(fmiString instanceName,
                              fmiType   fmuType, 
                              fmiString fmuGUID, 
                              fmiString fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn);

/**
 * \brief Dispose of the model instance.
 * 
 * @param c The FMU struct.
 */
void fmi2_free_instance(fmiComponent c);

/**
 * \brief Informs the FMU to setup the experiment
 * 
 * @param c The FMU struct.
 * @param toleranceDefined A fmiBoolean, states if the tolerance argument is valid.
 * @param tolerance The tolerance to use for the setup.
 * @param startTime The starting time of initializaton.
 * @param stopTimeDefined A fmiBoolean, states if the stopTime argument is valid.
 * @param stopTime The stop time of the simulation.
 */
fmiStatus fmi2_setup_experiment(fmiComponent c, 
                                fmiBoolean   toleranceDefined, 
                                fmiReal      tolerance, 
                                fmiReal      startTime, 
                                fmiBoolean   stopTimeDefined, 
                                fmiReal      stopTime);

/**
 * \brief Makes the FMU go into Initialization Mode.
 * 
 * @param c The FMU struct.
 */
fmiStatus fmi2_enter_initialization_mode(fmiComponent c);

/**
 * \brief Makes the FMU exit Initialization Mode.
 * 
 * @param c The FMU struct.
 */
fmiStatus fmi2_exit_initialization_mode(fmiComponent c);

/**
 * \brief Terminates the simulation run of the FMU.
 * 
 * @param c The FMU struct.
 */
fmiStatus fmi2_terminate(fmiComponent c);

/**
 * \brief Resets the FMU after a simulation run.
 * 
 * @param c The FMU struct.
 */
fmiStatus fmi2_reset(fmiComponent c);

/**
 * \brief Get Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_get_real(fmiComponent c, const fmiValueReference vr[],
                        size_t nvr, fmiReal value[]);

/**
 * \brief Get Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_get_integer(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, fmiInteger value[]);

/**
 * \brief Get Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_get_boolean(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, fmiBoolean value[]);

/**
 * \brief Get String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value (Output) Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_get_string(fmiComponent c, const fmiValueReference vr[],
                          size_t nvr, fmiString value[]);

/**
 * \brief Set Real values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_set_real(fmiComponent c, const fmiValueReference vr[],
                        size_t nvr, const fmiReal value[]);

/**
 * \brief Set Integer values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_set_integer(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, const fmiInteger value[]);

/**
 * \brief Set Boolean values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_set_boolean(fmiComponent c, const fmiValueReference vr[],
                           size_t nvr, const fmiBoolean value[]);

/**
 * \brief Set String values.
 * 
 * @param c The FMU struct.
 * @param vr Array of value-references.
 * @param nvr Number of array elements.
 * @param value Array of variable values.
 * @return Error code.
 */
fmiStatus fmi2_set_string(fmiComponent c, const fmiValueReference vr[],
                          size_t nvr, const fmiString value[]);


/**
 * \brief Get a copy of the FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate (Output) A pointer to the FMU state.
 * @return Error code.
 */
fmiStatus fmi2_get_fmu_state(fmiComponent c, fmiFMUstate* FMUstate);

/**
 * \brief Set the FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate The FMU state.
 * @return Error code.
 */
fmiStatus fmi2_set_fmu_state(fmiComponent c, fmiFMUstate FMUstate);

/**
 * \brief Free a FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate A pointer to a FMU state.
 * @return Error code.
 */
fmiStatus fmi2_free_fmu_state(fmiComponent c, fmiFMUstate* FMUstate);

/**
 * \brief Get the size of a byte vector needed for storing the FMU state.
 * 
 * @param c The FMU struct.
 * @param FMUstate A FMU state.
 * @param size (Output) The size of the FMU state. 
 * @return Error code.
 */
fmiStatus fmi2_serialized_fmu_state_size(fmiComponent c, fmiFMUstate FMUstate,
                                         size_t* size);

/**
 * \brief Serialize a FMU state into a byte vector.
 * 
 * @param c The FMU struct.
 * @param FMUstate A FMU state.
 * @param serializedState (Output) The FMU state serialized.
 * @param size The size of the FMU state. 
 * @return Error code.
 */
fmiStatus fmi2_serialized_fmu_state(fmiComponent c, fmiFMUstate FMUstate,
                                    fmiByte serializedState[], size_t size);

/**
 * \brief Deserialize a byte vector into a FMU state.
 * 
 * @param c The FMU struct.
 * @param serializedState The FMU state serialized.
 * @param size The size of the FMU state.
 * @param FMUstate (Output) A FMU state.
 * @return Error code.
 */
fmiStatus fmi2_de_serialized_fmu_state(fmiComponent c,
                                       const fmiByte serializedState[],
                                       size_t size, fmiFMUstate* FMUstate);

/**
 * \brief Evaluate directional derivative of ODE.
 *
 * @param c An FMU instance.
 * @param vUnknown_ref Value references of the directional derivative result
 *                     vector dz. These are defined by a subset of the
 *                     derivative and output variable value references.
 * @param nUnknown Size of z_vref vector.
 * @param vKnown_ref Value reference of the input seed vector dv. These 
 *                   are defined by a subset of the state and input
 *                   variable value references.
 * @param nKnown Size of v_vref vector.
 * @param dvKnown Input argument containing the input seed vector.
 * @param dvUnknown Output argument containing the directional derivative vector.
 * @return Error code.
 */
fmiStatus fmi2_get_directional_derivative(fmiComponent c,
                const fmiValueReference vUnknown_ref[], size_t nUnknown,
                const fmiValueReference vKnown_ref[],   size_t nKnown,
                const fmiReal dvKnown[], fmiReal dvUnknown[]);

 /* @} */

/**
 * \defgroup The Model Exchange public functions for FMI 2.0.
 * 
 * \brief Definitions of the functions for Model Exchange.
 */
 
 /* @{ */


/**
 * \brief Makes the simulation go into event mode.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi2_enter_event_mode(fmiComponent c);

/**
 * \brief Updates the FMU after an event. Does one event iteration.
 * 
 * @param c The FMU struct.
 * @param eventInfo (Output) An fmiEventInfo struct.
 * @return Error code.
 */
fmiStatus fmi2_new_discrete_state(fmiComponent  c,
                                  fmiEventInfo* fmiEventInfo);

/**
 * \brief Makes the simulation go into continuous time mode.
 * 
 * @param c The FMU struct.
 * @return Error code.
 */
fmiStatus fmi2_enter_continuous_time_mode(fmiComponent c);

/**
 * \brief Checks for step-events, can flush old FMU states and can terminate the simulation.
 * 
 * @param c The FMU struct.
 * @param noSetFMUStatePriorToCurrentPoint A fmiBoolean, can be used to 
 *                                         flush earlier saved FMU states.
 * @param enterEventMode (Output) A fmiBoolean.
 * @param terminateSimulation (Output) A fmiBoolean.
 * @return Error code.
 */
fmiStatus fmi2_completed_integrator_step(fmiComponent c,
                                         fmiBoolean   noSetFMUStatePriorToCurrentPoint, 
                                         fmiBoolean*  enterEventMode, 
                                         fmiBoolean*  terminateSimulation);

/**
 * \brief Set the current time.
 * 
 * @param c The FMU struct.
 * @param time The current time.
 * @return Error code.
 */
fmiStatus fmi2_set_time(fmiComponent c, fmiReal time);

/**
 * \brief Set the current states.
 * 
 * @param c The FMU struct.
 * @param x Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmiStatus fmi2_set_continuous_states(fmiComponent c, const fmiReal x[],
                                     size_t nx);

/**
 * \brief Calculates the derivatives.
 * 
 * @param c The FMU struct.
 * @param derivatives (Output) Array of the derivatives.
 * @param nx Number of derivatives.
 * @return Error code.
 */
fmiStatus fmi2_get_derivatives(fmiComponent c, fmiReal derivatives[], size_t nx);

/**
 * \brief Get the event indicators (for state-events)
 * 
 * @param c The FMU struct.
 * @param eventIndicators (Output) The event indicators.
 * @param ni Number of event indicators.
 * @return Error code.
 */
fmiStatus fmi2_get_event_indicators(fmiComponent c, 
                                    fmiReal eventIndicators[], size_t ni);
/**
 * \brief Get the current states.
 * 
 * @param c The FMU struct.
 * @param x (Output) Array of state values.
 * @param nx Number of states.
 * @return Error code.
 */
fmiStatus fmi2_get_continuous_states(fmiComponent c, fmiReal x[], size_t nx);

/**
 * \brief Get the nominal values of the states.
 * 
 * @param c The FMU struct.
 * @param x_nominal (Output) The nominal values.
 * @param nx Number of nominal values.
 * @return Error code.
 */
fmiStatus fmi2_get_nominals_of_continuous_states(fmiComponent c, 
                                                 fmiReal x_nominal[], 
                                                 size_t nx);

 /* @} */

/**
 * The Global Unique IDentifier is used to check that the XML file is compatible with the C functions.
 */
extern const char *C_GUID;

/**
 * \brief Instantiates the ME FMU, helper function for fmi2_instantiate.
 * 
 * @param c The FMU struct.
 * @param instanceName The name of the instance.
 * @param fmuType The fmi type to instanciate.
 * @param GUID The GUID identifier.
 * @param fmuResourceLocation The location of the resource directory.
 * @param functions Callback functions for logging, allocation and deallocation.
 * @param visible A fmiBoolean, defines the amount of interaction with the user.
 * @param loggingOn Turn of or on logging, fmiBoolean.
 * @return An instance of a model.
 */                                                 
fmiStatus fmi2_me_instantiate(fmiComponent c,
                              fmiString    instanceName,
                              fmiType      fmuType, 
                              fmiString    fmuGUID, 
                              fmiString    fmuResourceLocation, 
                              const fmiCallbackFunctions* functions, 
                              fmiBoolean                  visible,
                              fmiBoolean                  loggingOn);

/**
 * \brief Dispose of the ME model instance, helper function for fmi2_free_instance.
 * 
 * @param c The FMU struct.
 */
void fmi2_me_free_instance(fmiComponent c);

#endif
