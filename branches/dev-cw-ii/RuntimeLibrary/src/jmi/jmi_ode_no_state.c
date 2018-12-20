/*
    Copyright (C) 2009 Modelon AB

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

#include "jmi_ode_solver_impl.h"
#include "jmi_ode_problem.h"
#include "jmi_ode_no_state.h"
#include "jmi_log.h"

jmi_ode_status_t jmi_ode_no_state_solve(jmi_ode_solver_t* solver, double tend, int initialize){
    int flag = 0;
    jmi_ode_problem_t* problem = solver -> ode_problem;
    jmi_ode_sizes_t sizes = problem->sizes;
    char step_event = 0; /* boolean step_event = FALSE */
    char terminate = 0;
    int zero_crossning_event = 0;
    jmi_real_t tcur;
    size_t k;
    
    jmi_real_t* event_indicators = 0;
    jmi_real_t* event_indicators_previous = 0;
    
    if(sizes.event_indicators) {
        event_indicators          = solver->event_indicators;
        event_indicators_previous = solver->event_indicators_previous;
    }
    
    tcur = problem->time;
    
    /* Get the first event indicators */
    if(sizes.event_indicators > 0){
        flag = problem->ode_callbacks.root_func(tcur, NULL, event_indicators_previous, sizes, problem->problem_data);
            
        if (flag != 0){
            jmi_log_node(problem->log, logError, "NoStateSolver",
                    "Could not retrieve event indicators");
            return JMI_ODE_ERROR;
        }
    }
    problem->time = tend;
    
    /* Evaluate the model */
    flag = problem->ode_callbacks.rhs_func(tend, NULL, NULL, sizes, problem->problem_data);
    if (flag != 0){
        jmi_log_node(problem->log, logError, "NoStateSolver",
                "Could not retrieve time derivatives");
        return JMI_ODE_ERROR;
    }


    /* Check if an event indicator has triggered */
    if(sizes.event_indicators > 0){
        flag = problem->ode_callbacks.root_func(tend, NULL, event_indicators, sizes, problem->problem_data);
        
        if (flag != 0){
            jmi_log_node(problem->log, logError, "NoStateSolver",
                "Could not retrieve event indicators");
            return JMI_ODE_ERROR;
        }
    }

    for (k = 0; k < sizes.event_indicators; k++) {
        if (event_indicators[k]*event_indicators_previous[k] < 0) {
            zero_crossning_event = 1;
            break;
        }
    }
    memcpy(event_indicators_previous, event_indicators, sizes.event_indicators * sizeof(jmi_real_t));
        
    /* After each step call completed integrator step */
    flag = problem->ode_callbacks.complete_step_func(&step_event, &terminate, problem->problem_data);
    if (flag != 0) {
        jmi_log_node(problem->log, logError, "Error", "Failed to complete an integrator step. "
                 "Returned with <error_flag: %d>", flag);
        return JMI_ODE_ERROR;
    }
        
    /* Handle events */
    if (zero_crossning_event || step_event == TRUE) {
        jmi_log_node(problem->log, logInfo, "EulerEvent", "An event was detected at <t:%g>", tend);
        return JMI_ODE_EVENT;
    }
    
    if (terminate == TRUE) {
        jmi_log_node(problem->log, logInfo, "Terminate",
            "Terminating simulation after a signal from the model at <t:%g>", tend);
        return JMI_ODE_TERMINATE;
    }

    return JMI_ODE_OK;
}



int jmi_ode_no_state_new(jmi_ode_no_state_t** integrator_ptr, jmi_ode_solver_t* solver) {
    jmi_ode_no_state_t* integrator;
    jmi_ode_problem_t* problem = solver -> ode_problem;
    
    integrator = (jmi_ode_no_state_t*)calloc(1,sizeof(jmi_ode_no_state_t));
    if(!integrator){
        jmi_log_node(problem->log, logError, "NoStateSolver",
            "Failed to allocate the internal struct.");
        return -1;
    }
    *integrator_ptr = integrator;
    return 0;
}

void jmi_ode_no_state_delete(jmi_ode_solver_t* solver) {    
    if((jmi_ode_no_state_t*)(solver->integrator)){
        free((jmi_ode_no_state_t*)(solver->integrator));
    }
}
