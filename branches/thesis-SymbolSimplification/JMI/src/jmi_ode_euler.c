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

#include "jmi_ode_solver.h"
#include "jmi_ode_euler.h"
#include "fmi1_cs.h"
#include "fmi1_me.h"
#include "jmi_log.h"

int jmi_ode_euler_solve(jmi_ode_solver_t* solver, double tend, int initialize){
    int flag = 0;
    jmi_ode_euler_t* integrator = (jmi_ode_euler_t*)solver->integrator;
    fmi1_cs_t* fmi1_cs = solver->fmi1_cs;
    int n_real_x = fmi1_cs->n_real_x;
    int n_sw = fmi1_cs->n_sw;
    fmiBoolean step_event = fmiFalse;
    
    jmi_real_t tcur, tnext;
    jmi_real_t hcur;
    jmi_real_t hdef;
    
    jmi_real_t* y = 0;
    jmi_real_t* ydot = 0;
    jmi_real_t* event_indicators = 0;
    jmi_real_t* event_indicators_previous = 0;
    
    hdef = integrator->step_size;

    /* if(n_real_x) { */
    y = fmi1_cs->states;
    ydot = fmi1_cs->states_derivative;
    
    
    if(n_sw) {
        event_indicators = fmi1_cs->event_indicators;
        event_indicators_previous = fmi1_cs->event_indicators_previous;

    }
    
    flag = fmi1_cs_get_time((fmiComponent)fmi1_cs, &tcur);
    if (flag != fmiOK) {
        return JMI_ODE_ERROR;
    }
    /* tcur = fmi1_cs->time; */
    hcur = hdef;
    
    /* Get the first event indicators */
    if(n_sw > 0){
        flag = fmi1_cs_root_fcn(fmi1_cs, tcur, y, event_indicators_previous);
            
        if (flag != 0){
            jmi_log_comment(fmi1_cs_get_jmi_t_log(fmi1_cs), logError, "Could not retrieve event indicators");
            return -1;
        }
    }

    while ( tcur < tend ) {
        size_t k;
        int zero_crossning_event = 0;
        /*int time_event = 0; */

        /* Get derivatives */
        /* if(n_real_x > 0) { */
        flag = fmi1_cs_rhs_fcn(fmi1_cs, tcur, y, ydot);
        if (flag != 0){
            jmi_log_comment(fmi1_cs_get_jmi_t_log(fmi1_cs), logError, "Could not retrieve time derivatives");
            return -1;
        }

        /* Choose time step and advance tcur */
        tnext = tcur + hdef;

        /* adjust tnext step to get tend exactly */ 
        if(tnext > tend - hdef/1e16) {
            tnext = tend;               
        }

        hcur = tnext - tcur;
        tcur = tnext;
        
        /* *tout = tcur; */
        
        /* integrate */
        for (k = 0; k < n_real_x; k++) {
            y[k] = y[k] + hcur*ydot[k]; 
        }
        
        /* Check if an event indicator has triggered */
        if(n_sw > 0){
            flag = fmi1_cs_root_fcn(fmi1_cs, tcur, y, event_indicators);
            
            if (flag != 0){
                jmi_log_comment(fmi1_cs_get_jmi_t_log(fmi1_cs), logError, "Could not retrieve event indicators");
                return -1;
            }
        }

        for (k = 0; k < n_sw; k++) {
            if (event_indicators[k]*event_indicators_previous[k] < 0) {
                zero_crossning_event = 1;
                break;
            }
        }
        memcpy(event_indicators_previous, event_indicators, (fmi1_cs->n_sw)*sizeof(jmi_real_t));
        
        /* After each step call completed integrator step */
        flag = fmi1_cs_completed_integrator_step((fmiComponent)fmi1_cs, &step_event);
        if (flag != fmiOK) {
            jmi_log_node(fmi1_cs_get_jmi_t_log(fmi1_cs), logError, "Error", "Failed to complete an integrator step. "
                     "Returned with <error_flag: %d>", flag);
            return JMI_ODE_ERROR;
        }
        
        /* Handle events */
        if (zero_crossning_event || step_event == fmiTrue) {
            jmi_log_node(fmi1_cs_get_jmi_t_log(fmi1_cs), logInfo, "EulerEvent", "An event was detected at <t:%g>", tcur);
            return JMI_ODE_EVENT;
        }

    } /* while */
    
    /* Final call to the RHS */
    flag = fmi1_cs_rhs_fcn(fmi1_cs, tcur, y, ydot);
    if (flag != 0){
        jmi_log_comment(fmi1_cs_get_jmi_t_log(fmi1_cs), logError, "Could not retrieve time derivatives");
        return -1;
    }
    
    return JMI_ODE_OK;  
}



int jmi_ode_euler_new(jmi_ode_euler_t** integrator_ptr, jmi_ode_solver_t* solver) {
    jmi_ode_euler_t* integrator;
    fmi1_cs_t* fmi1_cs = solver->fmi1_cs;
    fmi_t* fmi1_me = (fmi_t*)fmi1_cs->fmi1_me;
    
    integrator = (jmi_ode_euler_t*)calloc(1,sizeof(jmi_ode_euler_t));
    if(!integrator){
        jmi_log_comment(fmi1_cs_get_jmi_t_log(fmi1_cs), logError, "Failed to allocate the internal EULER struct.");
        return -1;
    }
    /* DEFAULT VALUES NEEDS TO BE IMPROVED*/
    /* integrator->step_size = 0.001; */
    integrator->step_size = fmi1_me->jmi->options.cs_step_size;

    *integrator_ptr = integrator;
    return 0;
}

void jmi_ode_euler_delete(jmi_ode_solver_t* solver) {    
    if((jmi_ode_euler_t*)(solver->integrator)){
        free((jmi_ode_euler_t*)(solver->integrator));
    }
}
