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


#include "jmi_ode_problem.h"

int jmi_new_ode_problem(jmi_ode_problem_t** ode_problem, void* fmix_me,
                       int n_real_x, int n_sw, int n_real_u, jmi_log_t* log){
    int i;
    jmi_ode_problem_t* problem;
    
    *ode_problem = (jmi_ode_problem_t*)calloc(1,sizeof(jmi_ode_problem_t));
    problem = *ode_problem;
    problem -> fmix_me  = fmix_me;     
    problem -> n_real_x = n_real_x;
    problem -> n_sw     = n_sw;
    problem -> n_real_u = n_real_u;
    problem -> states                    = (jmi_real_t*)calloc(n_real_x, sizeof(jmi_real_t));
    problem -> states_derivative         = (jmi_real_t*)calloc(n_real_x, sizeof(jmi_real_t));
    problem -> nominal                   = (jmi_real_t*)calloc(n_real_x, sizeof(jmi_real_t));
    problem -> event_indicators          = (jmi_real_t*)calloc(n_sw, sizeof(jmi_real_t));
    problem -> event_indicators_previous = (jmi_real_t*)calloc(n_sw, sizeof(jmi_real_t));
    problem -> log = log;
    
    problem -> inputs = (jmi_cs_input_t*)calloc(n_real_u, sizeof(jmi_cs_input_t));
    /* Initialize inputs */
    for (i = 0; i < n_real_u; i++) {
        jmi_cs_init_input_struct(&(problem -> inputs[i]));
    }
    
    return 0;
}

int jmi_init_ode_problem(jmi_ode_problem_t* problem, jmi_real_t t_start,
                         rhs_func_t rhs_func, root_func_t root_func, 
                         complete_step_func_t complete_step_func) {
    
    problem -> time               = t_start;
    problem -> rhs_func           = rhs_func;
    problem -> root_func          = root_func;
    problem -> complete_step_func = complete_step_func;
    
    return 0;
}


void jmi_free_ode_problem(jmi_ode_problem_t* problem){
    if (problem) {
        free(problem -> states);
        free(problem -> states_derivative);
        free(problem -> nominal);
        free(problem -> event_indicators);
        free(problem -> event_indicators_previous);
        free(problem -> inputs);
        free(problem);
    }
}
    
