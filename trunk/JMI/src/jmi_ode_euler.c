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

int jmi_ode_euler_solve(jmi_ode_solver_t* solver, double tend, int initialize){
    int flag = 0;
	jmi_ode_euler_t* integrator = (jmi_ode_euler_t*)solver->integrator;
    jmi_t* jmi = solver->jmi;
    int n_states = solver->n_real_x;
	int n_event_indicators = solver->n_sw;

	jmi_real_t tcur, tnext;
	jmi_real_t hcur;
	jmi_real_t hdef;
	
	jmi_real_t* y = 0;
	jmi_real_t* ydot = 0;
	jmi_real_t* event_indicators = 0;
	jmi_real_t* event_indicators_pre = 0;
	
    hdef = integrator->step_size;

	if(n_states) {
		y = integrator->y_work;
		ydot = integrator->ydot_work;

	}
	if(n_event_indicators) {
		event_indicators = integrator->event_indicators;
		event_indicators_pre = integrator->event_indicators_pre;

	}

	tcur = *(jmi_get_t(solver->jmi));
	hcur = hdef;
    
    /* Get the first event indicators */
    if(n_event_indicators > 0){
        flag = solver->root_fcn(solver->user_data, tcur, y, event_indicators_pre);
            
        if (flag != 0){
            jmi_log_comment(solver->jmi->log, logError, "Could not retrieve event indicators");
            return -1;
        }
    }

    while ( tcur < tend ) {
		size_t k;
		int zero_crossning_event = 0;
		int time_event = 0;

		/* Get derivatives */
		if(n_states > 0) {
            flag = solver->rhs_fcn(solver->user_data, tcur, y, ydot);
            
            if (flag != 0){
                jmi_log_comment(solver->jmi->log, logError, "Could not retrieve time derivatives");
                return -1;
            }
		}

		/* Choose time step and advance tcur */
		tnext = tcur + hdef;

		/* adjust tnext step to get tend exactly */ 
		if(tnext > tend - hdef/1e16) {
			tnext = tend;				
		}

		hcur = tnext - tcur;
		tcur = tnext;
        
        /* set solver tout */
        solver->tout = tcur;
        
		/* integrate */
		for (k = 0; k < n_states; k++) {
			y[k] = y[k] + hcur*ydot[k];	
		}
        
		/* Check if an event indicator has triggered */
		if(n_event_indicators > 0){
            flag = solver->root_fcn(solver->user_data, tcur, y, event_indicators);
            
            if (flag != 0){
                jmi_log_comment(solver->jmi->log, logError, "Could not retrieve event indicators");
                return -1;
            }
		}

		for (k = 0; k < n_event_indicators; k++) {
			if (event_indicators[k]*event_indicators_pre[k] < 0) {
				zero_crossning_event = 1;
				break;
			}
		}
        memcpy(event_indicators_pre, event_indicators, (solver->n_sw)*sizeof(jmi_real_t));
        
		/* Handle events */
		if (zero_crossning_event) {
                    jmi_log_node(solver->jmi->log, logInfo, "EulerEvent", "<An event was detected at> t:%g", tcur);
            return JMI_ODE_EVENT;
		}

	} /* while */
    
    return JMI_ODE_OK;	
}



int jmi_ode_euler_new(jmi_ode_euler_t** integrator_ptr, jmi_ode_solver_t* solver) {
    jmi_ode_euler_t* integrator;
    jmi_t* jmi = solver->jmi;
    
	integrator = (jmi_ode_euler_t*)calloc(1,sizeof(jmi_ode_euler_t));
    if(!integrator){
        jmi_log_comment(jmi->log, logError, "Failed to allocate the internal EULER struct.");
        return -1;
    }

	/* DEFAULT VALUES NEEDS TO BE IMPROVED*/
	integrator->step_size = 0.001;

	/* Allocate work vectors */
	integrator->y_work = calloc(solver->n_real_x,sizeof(jmi_real_t));
    integrator->ydot_work = calloc(solver->n_real_x,sizeof(jmi_real_t));
    integrator->event_indicators = calloc(solver->n_sw,sizeof(jmi_real_t));
    integrator->event_indicators_pre = calloc(solver->n_sw,sizeof(jmi_real_t));
    
    memcpy(integrator->y_work, jmi_get_real_x(jmi), (solver->n_real_x)*sizeof(jmi_real_t));
      
    *integrator_ptr = integrator;
    return 0;
}

void jmi_ode_euler_delete(jmi_ode_solver_t* solver) {
    
    if((jmi_ode_euler_t*)(solver->integrator)){
		/*Deallocate work vectors.*/
        free((((jmi_ode_euler_t*)(solver->integrator))->y_work));
        free((((jmi_ode_euler_t*)(solver->integrator))->ydot_work));
		free((((jmi_ode_euler_t*)(solver->integrator))->event_indicators));
        free((((jmi_ode_euler_t*)(solver->integrator))->event_indicators_pre));
        
        free((jmi_ode_euler_t*)(solver->integrator));
    }
}
